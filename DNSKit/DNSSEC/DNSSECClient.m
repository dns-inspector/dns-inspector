#import "DNSSECClient.h"
#import "DNSSECClient+Private.h"
#import "DNSRecordData+Private.h"
#import "DNSDNSKEYRecordData+Private.h"
#import "DNSRRSIGRecordData+Private.h"
#import "DNSAnswer+Private.h"
#import "DNSSECResource.h"
#import "DNSName.h"
@import Security;

@implementation DNSSECClient

+ (void) authenticateMessage:(DNSMessage *)message usingClient:(DNSClient *)client withResult:(void (^)(NSError *))completed {
    DNSRRSIGRecordData * rrsigData;
    DNSAnswer * rrsig;

    for (DNSAnswer * answer in message.answers) {
        if (answer.recordType != DNSRecordTypeRRSIG) {
            continue;
        }
        rrsig = answer;
        rrsigData = (DNSRRSIGRecordData *)answer.data;
        break;
    }

    if (rrsig == nil) {
        completed(MAKE_ERROR(DNSSECErrorNoSignatures, @"No record signatures included in message"));
        return;
    }

    switch(rrsigData.algorithm) {
        case DNSSECAlgorithmRSA_SHA256:
        case DNSSECAlgorithmRSA_SHA512:
        case DNSSECAlgorithmECDSAP256_SHA256:
        case DNSSECAlgorithmECDSAP384_SHA384:
            // DNSKit only supports these algorithms
            break;
        default:
            completed(MAKE_ERROR(DNSSECErrorUnsupportedAlgorithm, @"Unsupported DNSSEC algorithm"));
            return;
    }

    NSError * zoneKeyError;
    NSArray<DNSSECResource *> * resources = [DNSSECClient getKeyChainStartingAt:rrsigData.signerName withClient:client error:&zoneKeyError];
    if (zoneKeyError != nil) {
        completed(zoneKeyError);
        return;
    }
    if (resources == nil || resources.count == 0) {
        completed(MAKE_ERROR(DNSSECErrorMissingKeys, @"No signing keys found"));
        return;
    }

    // Double check that the root KSK is what we expect
    NSData * trustedRootKsk = [NSData dataWithBytes:rootKSK length:260];
    DNSSECResource * root = resources[resources.count-1];
    bool foundRootKsk = false;
    for (DNSDNSKEYRecordData * rootKey in root.keys) {
        if (!rootKey.keySigningKey) {
            continue;
        }
        foundRootKsk = true;

        if (![trustedRootKsk isEqualToData:rootKey.publicKey]) {
            PError(@"Root KSK did not match expected value. Expected '%@' got '%@'", [trustedRootKsk description], [rootKey.publicKey description]);
            completed(MAKE_ERROR(DNSSECErrorUntrustedRootSigningKey, @"Untrusted root key signing key"));
            return;
        }

        PDebug(@"Root zone KSK matched trusted value");
    }

    if (!foundRootKsk) {
        PError(@"No root KSK found");
        completed(MAKE_ERROR(DNSSECErrorUntrustedRootSigningKey, @"Untrusted root key signing key"));
        return;
    }

    // signature = sign(RRSIG_RDATA | RR(1) | RR(2)... )
    // RR(i) = owner | type | class | TTL | RDATA length | RDATA

    NSMutableData * signatureData = [NSMutableData new];
    [signatureData appendData:rrsigData.signedData];
    for (DNSAnswer * answer in message.answers) {
        if (![answer.name isEqualToString:rrsig.name]) {
            continue;
        }
        if (answer.recordType != rrsigData.typeCovered) {
            continue;
        }
        if (answer.recordClass != rrsig.recordClass) {
            continue;
        }
        [signatureData appendData:[DNSName stringToDNSName:answer.name error:nil]];

        uint16_t atype = htons(answer.recordType);
        uint16_t aclass = htons(answer.recordClass);
        uint32_t ttl = htonl(answer.ttlSeconds);
        uint16_t rdlen = htonl(answer.dataLength);
        [signatureData appendBytes:&atype length:2];
        [signatureData appendBytes:&aclass length:2];
        [signatureData appendBytes:&ttl length:4];
        [signatureData appendBytes:&rdlen length:2];
        [signatureData appendData:answer.data.recordValue];
    }

    // Starting at the TLD, verify that the zone's key was signed by the parent KSK
    completed(nil);
    return;
}

/// Get the chain of keys & signatures starting from the given name, going all the way to the root zone
/// - Parameters:
///   - name: The name to start from.
///   - client: The DNSClient to use for performing queries.
///   - error: Populated if an error occured getting the resources
+ (NSArray<DNSSECResource *> *) getKeyChainStartingAt:(NSString *)name withClient:(DNSClient *)client error:(NSError **)error {
    NSMutableArray<NSString *> * names = [NSMutableArray new];
    NSString * nextName = name;
    int keysNeeded = 0; // How many keys we need
    int __block keysFetched = 0; // How many keys were successfully fetched
    int __block questionsFinished = 0; // How many questions we got a reply to (even if we got an error)
    while (true) {
        [names addObject:nextName];
        keysNeeded++;

        NSArray<NSString *> * nameParts = [nextName componentsSeparatedByString:@"."];
        if (nameParts[0].length == 0) {
            break;
        } else {
            nextName = [[nameParts subarrayWithRange:NSMakeRange(1, nameParts.count-1)] componentsJoinedByString:@"."];
            if (nextName.length == 0) {
                nextName = @".";
            }
        }
    }

    NSObject * lock = [NSObject new];
    NSMutableArray<NSError *> * dnskeyErrors = [NSMutableArray arrayWithCapacity:keysNeeded];
    NSMutableArray<NSArray<DNSDNSKEYRecordData *> *> * dnskeys = [NSMutableArray arrayWithCapacity:keysNeeded];
    NSMutableArray<DNSRRSIGRecordData *> * rrsigs = [NSMutableArray arrayWithCapacity:keysNeeded];

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);

    // Get all the resource we need in parallel
    for (int i = 0; i < keysNeeded; i++) {
        DNSQuestion * question = [[DNSQuestion alloc] initWithName:names[i] recordType:DNSRecordTypeDNSKEY recordClass:DNSRecordClassIN];
        PDebug(@"Getting DNSKEY keys for %@", question.name);
        DNSMessage * message = [DNSMessage new];
        message.idNumber = arc4random_uniform(UINT16_MAX);
        message.dnssecOK = true;
        message.questions = @[question];
        int __block index = i;
        [client sendMessage:message gotReply:^(DNSMessage * reply, NSError * error) {
            if (error != nil) {
                @synchronized (lock) {
                    [dnskeyErrors insertObject:error atIndex:index];
                }
            } else if (reply.responseCode != DNSResponseCodeSuccess) {
                @synchronized (lock) {
                    NSString * errorDescription = [NSString stringWithFormat:@"No DNSKEY record for %@", reply.questions[0].name];
                    [dnskeyErrors insertObject:MAKE_ERROR(-1, errorDescription) atIndex:index];
                }
            } else {
                bool gotDNSKEY = false;
                bool gotRRSIG = false;
                NSMutableArray<DNSDNSKEYRecordData *> * zoneKeys = [NSMutableArray new];
                DNSRRSIGRecordData * zoneSig;
                for (DNSAnswer * answer in reply.answers) {
                    switch (answer.recordType) {
                        case DNSRecordTypeRRSIG: {
                            DNSRRSIGRecordData * data = (DNSRRSIGRecordData *)answer.data;
                            zoneSig = data;
                            gotRRSIG = true;
                            break;
                        } case DNSRecordTypeDNSKEY: {
                            DNSDNSKEYRecordData * data = (DNSDNSKEYRecordData *)answer.data;
                            [zoneKeys addObject:data];
                            gotDNSKEY = true;
                            break;
                        } default:
                            break;
                    }
                }

                @synchronized (lock) {
                    if (!gotDNSKEY || !gotRRSIG) {
                        NSString * errorDescription = [NSString stringWithFormat:@"No DNSKEY or RRSIG record for %@", reply.questions[0].name];
                        [dnskeyErrors insertObject:MAKE_ERROR(-1, errorDescription) atIndex:index];
                    } else {
                        [dnskeys insertObject:zoneKeys atIndex:index];
                        [rrsigs insertObject:zoneSig atIndex:index];
                        keysFetched++;
                    }
                }
            }

            @synchronized (lock) {
                questionsFinished++;
                if (questionsFinished == keysNeeded) {
                    dispatch_semaphore_signal(sync);
                }
            }
        }];
    }

    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));

    if (keysFetched != keysNeeded) {
        PError(@"Unable to query for all keys in domain");
        *error = MAKE_ERROR(DNSSECErrorMissingKeys, @"One or more DNSKEY not found");
        return nil;
    }

    NSMutableArray<DNSSECResource *> * resources = [NSMutableArray arrayWithCapacity:keysNeeded];
    
    for (int i = 0; i < keysNeeded; i++) {
        DNSSECResource * resource = [DNSSECResource new];
        resource.name = names[i];
        resource.keys = dnskeys[i];
        resource.rrsig = rrsigs[i];
        [resources insertObject:resource atIndex:i];
    }

    PInfo(@"Fetched %i keys", (int)keysFetched);
    return resources;
}

+ (NSError *) validateAnswers:(NSArray<DNSAnswer *> *)answers withSignature:(DNSAnswer *)rrsigAnswer againstKey:(DNSAnswer *)dnskeyAnswer {
    if (answers.count == 0) {
        return MAKE_ERROR(DNSSECInvalidResponse, @"Empty RRSet");
    }

    // All answers must have the same name, type, and class
    for (int i = 1; i < answers.count; i++) {
        if (![answers[i].name isEqualToString:answers[0].name]) {
            return MAKE_ERROR(DNSSECInvalidResponse, @"Mismatched names in RRSet");
        }
        if (answers[i].recordType != answers[0].recordType) {
            return MAKE_ERROR(DNSSECInvalidResponse, @"Mismatched types in RRSet");
        }
        if (answers[i].recordClass != answers[0].recordClass) {
            return MAKE_ERROR(DNSSECInvalidResponse, @"Mismatched classes in RRSet");
        }
    }

    DNSRRSIGRecordData * rrsig = (DNSRRSIGRecordData *)rrsigAnswer.data;
    DNSDNSKEYRecordData * dnskey = (DNSDNSKEYRecordData *)dnskeyAnswer.data;

    if (rrsig.keyTag != [dnskey keyTag]) {
        return MAKE_ERROR(DNSSECBadSigningKey, @"Mismatched keytag from signature");
    }
    if (rrsigAnswer.recordClass != dnskeyAnswer.recordClass) {
        return MAKE_ERROR(DNSSECBadSigningKey, @"Mismatched record class from signature");
    }
    if (rrsig.algorithm != dnskey.algoritm) {
        return MAKE_ERROR(DNSSECBadSigningKey, @"Mismatched algorithm from signature");
    }
    if (![rrsig.signerName.lowercaseString isEqualToString:dnskeyAnswer.name.lowercaseString]) {
        return MAKE_ERROR(DNSSECBadSigningKey, @"Mismatched signer name from signature");
    }
    if (dnskey.protocol != 3) {
        return MAKE_ERROR(DNSSECBadSigningKey, @"Bad key protocol");
    }
    if (!dnskey.zoneKey) {
        return MAKE_ERROR(DNSSECBadSigningKey, @"Improper zone key usage");
    }
    if (answers[0].recordClass != rrsigAnswer.recordClass) {
        return MAKE_ERROR(DNSSECBadSigningKey, @"Mismatched record class from signature");
    }
    if (answers[0].recordType != rrsig.typeCovered) {
        return MAKE_ERROR(DNSSECBadSigningKey, @"Mismatched record type from signature");
    }

    NSMutableData * signeddata = [NSMutableData dataWithData:[rrsig signedData]];

    NSComparisonResult (^sortAnswers)(DNSAnswer *, DNSAnswer *) = ^(DNSAnswer * left, DNSAnswer * right)
    {
        int r = [DNSAnswer compareLeft:left withRight:right];

        if (r == 0) {
            return NSOrderedSame;
        } else if (r < 0) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    };

    NSArray<DNSAnswer *> * sortedAnswers = [answers sortedArrayUsingComparator:sortAnswers];
    for (DNSAnswer * answer in sortedAnswers) {
        [signeddata appendData:[answer rawSignatureData:rrsig]];
    }

    NSError * keyError;
    SecKeyRef publicKey = [dnskey parsePublicKey:&keyError];
    if (keyError != nil) {
        NSString * message = [NSString stringWithFormat:@"Invalid public key: %@", keyError.localizedDescription];
        return MAKE_ERROR(DNSSECBadSigningKey, message);
    }

    SecKeyAlgorithm algo;
    switch (rrsig.algorithm) {
        case DNSSECAlgorithmRSA_SHA256:
            algo = kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA256;
            break;
        case DNSSECAlgorithmRSA_SHA512:
            algo = kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA512;
            break;
        case DNSSECAlgorithmECDSAP256_SHA256:
            algo = kSecKeyAlgorithmECDSASignatureMessageX962SHA256;
            break;
        case DNSSECAlgorithmECDSAP384_SHA384:
            algo = kSecKeyAlgorithmECDSASignatureMessageX962SHA384;
            break;
        default:
            return MAKE_ERROR(DNSSECErrorUnsupportedAlgorithm, @"Unsupported algorithm");
    }

    NSData * signature = [rrsig signatureForCrypto];

    CFErrorRef verifyError;
    bool verfieid = SecKeyVerifySignature(publicKey, algo, (__bridge CFDataRef)signeddata, (__bridge CFDataRef)signature, &verifyError);
    CFRelease(publicKey);

    if (!verfieid) {
        return MAKE_ERROR(DNSSECSignatureFailed, @"Signature validation failed");
    }

    return nil;
}

@end
