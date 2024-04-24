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

+ (void) authenticateMessage:(DNSMessage *)message usingClient:(DNSClient *)client withResult:(void (^)(DNSSECResult *))completed {
    DNSSECResult * result = [DNSSECResult new];

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
        result.signatureError = MAKE_ERROR(DNSSECErrorNoSignatures, @"No record signatures included in message");
        completed(result);
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
            result.signatureError = MAKE_ERROR(DNSSECErrorUnsupportedAlgorithm, @"Unsupported DNSSEC algorithm");
            completed(result);
            return;
    }

    NSError * zoneKeyError;
    NSArray<DNSSECResource *> * resources = [DNSSECClient getKeyChainStartingAt:rrsigData.signerName withClient:client error:&zoneKeyError];
    if (zoneKeyError != nil) {
        result.signatureError = zoneKeyError;
        completed(result);
        return;
    }
    if (resources == nil || resources.count == 0) {
        result.signatureError = MAKE_ERROR(DNSSECErrorMissingKeys, @"No signing keys found");
        completed(result);
        return;
    }

    // Double check that the root KSK is what we expect
    NSData * trustedRootKsk = [NSData dataWithBytes:rootKSK length:260];
    DNSSECResource * root = resources[resources.count-1];
    bool foundRootKsk = false;
    for (DNSAnswer * rootKeyAnswer in root.dnsKeys) {
        DNSDNSKEYRecordData * rootKey = (DNSDNSKEYRecordData *)rootKeyAnswer.data;
        if (!rootKey.keySigningKey) {
            continue;
        }
        foundRootKsk = true;

        if (![trustedRootKsk isEqualToData:rootKey.publicKey]) {
            PError(@"Root KSK did not match expected value. Expected '%@' got '%@'", [trustedRootKsk description], [rootKey.publicKey description]);
            result.chainError = MAKE_ERROR(DNSSECErrorUntrustedRootSigningKey, @"Untrusted root key signing key");
            completed(result);
            return;
        }

        PDebug(@"Root zone KSK matched trusted value");
    }

    if (!foundRootKsk) {
        PError(@"No root KSK found");
        result.chainError = MAKE_ERROR(DNSSECErrorUntrustedRootSigningKey, @"Untrusted root key signing key");
        completed(result);
        return;
    }

    // Starting at the furthest descdent zone:
    // - Verify the signature of the original message against its RR and the DNSKEY we fetched
    // - Verify the signature of the DNSKEY message
    // - Verify the DS record of each parent zoon, until the root
    // If all of the above tests pass, then we can attest full trust of the chain

    // Verify the signature of the original message against its RR and the DNSKEY we fetched
    {
        NSMutableArray<DNSAnswer *> * rrset = [NSMutableArray new];
        DNSAnswer * rrsigAnswer;

        for (DNSAnswer * answer in message.answers) {
            if (answer.recordType == DNSRecordTypeRRSIG) {
                rrsigAnswer = answer;
                continue;
            } else {
                [rrset addObject:answer];
            }
        }

        DNSRRSIGRecordData * rrsig = (DNSRRSIGRecordData *)rrsigAnswer.data;

        // Find the matching key
        DNSAnswer * zsk = nil;
        for (DNSAnswer * dnskey in resources[0].dnsKeys) {
            DNSDNSKEYRecordData * key = (DNSDNSKEYRecordData *)dnskey.data;
            if ([key keyTag] == rrsig.keyTag) {
                zsk = dnskey;
                break;
            }
        }

        if (zsk == nil) {
            PError(@"No key with tag %lu found on zone", (unsigned long)rrsig.keyTag);
            result.signatureError = MAKE_ERROR(DNSSECErrorMissingKeys, @"No matching key found");
            completed(result);
            return;
        }

        NSError * validationError = [DNSSECClient validateAnswers:rrset withSignature:rrsigAnswer againstKey:zsk];
        if (validationError != nil) {
            result.signatureError = validationError;
            completed(result);
            return;
        }

        result.signatureVerified = true;
    }

    // Verify the signature of the DNSKEY message
    {
        NSArray<DNSAnswer *> * keyAnswers = resources[0].dnsKeys;
        DNSAnswer * rrsigAnswer = resources[0].keySigs;
        DNSRRSIGRecordData * rrsig = (DNSRRSIGRecordData *)rrsigAnswer.data;

        // Find the matching key
        DNSAnswer * ksk = nil;
        for (DNSAnswer * dnskey in resources[0].dnsKeys) {
            DNSDNSKEYRecordData * key = (DNSDNSKEYRecordData *)dnskey.data;
            if ([key keyTag] == rrsig.keyTag) {
                ksk = dnskey;
                break;
            }
        }

        if (ksk == nil) {
            PError(@"No key with tag %lu found on zone", (unsigned long)rrsig.keyTag);
            result.chainError = MAKE_ERROR(DNSSECErrorMissingKeys, @"No matching key found");
            completed(result);
            return;
        }

        NSError * validationError = [DNSSECClient validateAnswers:keyAnswers withSignature:rrsigAnswer againstKey:ksk];
        if (validationError != nil) {
            result.chainError = validationError;
            completed(result);
            return;
        }
    }

    // Verify the DS record of each parent zoon, until the root
    for (int i = 0; i < resources.count-1; i++) {
        DNSAnswer * dsAnswer = resources[i].ds;
        if (dsAnswer == nil) {
            PError(@"No DS record found on zone");
            result.chainError = MAKE_ERROR(DNSSECErrorNoSignatures, @"Missing DS record");
            completed(result);
            return;
        }
        DNSDSRecordData * ds = (DNSDSRecordData *)dsAnswer.data;

        // Check the ds digest
        {
            BOOL digestMatched = false;
            for (DNSAnswer * answer in resources[i].dnsKeys) {
                DNSDNSKEYRecordData * dnskey = (DNSDNSKEYRecordData *)answer.data;
                NSUInteger keyTag = [dnskey keyTag];
                if (ds.keyTag != keyTag) {
                    continue;
                }

                NSData * digest = [dnskey hashWithOwnerName:dsAnswer.name algorithm:ds.digestType];
                if ([digest isEqualToData:ds.digest]) {
                    digestMatched = true;
                    break;
                }
            }

            if (!digestMatched) {
                PError(@"No matching DNSKEY found from DS digest");
                result.chainError = MAKE_ERROR(DNSSECErrorMissingKeys, @"Unknown DNSKEY referenced in DS record");
                completed(result);
                return;
            }
        }

        DNSAnswer * rrsigAnswer = resources[i].dsSigs;
        if (rrsigAnswer == nil) {
            PError(@"No matching RRSIG record found for DS record on zone");
            result.chainError = MAKE_ERROR(DNSSECErrorNoSignatures, @"Missing DS record signature");
            completed(result);
            return;
        }
        DNSRRSIGRecordData * rrsig = (DNSRRSIGRecordData *)rrsigAnswer.data;

        // DS Records are signed by their parent zone's key
        DNSAnswer * dnskeyAnswer = nil;
        for (DNSAnswer * answer in resources[i+1].dnsKeys) {
            DNSDNSKEYRecordData * dnskey = (DNSDNSKEYRecordData *)answer.data;
            if ([dnskey keyTag] == rrsig.keyTag) {
                dnskeyAnswer = answer;
                break;
            }
        }
        if (dnskeyAnswer == nil) {
            PError(@"No key with key tag %lu found on zone", (unsigned long)rrsig.keyTag);
            result.chainError = MAKE_ERROR(DNSSECErrorMissingKeys, @"Missing DNSKEY for RRSIG");
            completed(result);
            return;
        }

        NSError * validationError = [DNSSECClient validateAnswers:@[dsAnswer] withSignature:rrsigAnswer againstKey:dnskeyAnswer];
        if (validationError != nil) {
            PError(@"RRSIG validation failure for DS record");
            result.chainError = validationError;
            completed(result);
            return;
        }
    }
    result.chainTrusted = true;

    completed(result);
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
    int __block questionsToSend = 0;
    int __block questionsAnswered = 0;
    while (true) {
        [names addObject:nextName];
        questionsToSend += 2; // DNSKEY + DS question per zone

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
    NSMutableArray<NSError *> * dnskeyErrors = [NSMutableArray arrayWithCapacity:names.count];
    NSMutableArray<NSError *> * dsErrors = [NSMutableArray arrayWithCapacity:names.count];
    NSMutableArray<NSArray<DNSAnswer *> *> * dnskeys = [NSMutableArray arrayWithCapacity:names.count];
    NSMutableArray<NSArray<DNSAnswer *> *> * dss = [NSMutableArray arrayWithCapacity:names.count];

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);

    // Get all the resource we need in parallel
    for (int i = 0; i < names.count; i++) {
        // Get the DNSKEy for thiz zone
        DNSQuestion * dnskeyQuestion = [[DNSQuestion alloc] initWithName:names[i] recordType:DNSRecordTypeDNSKEY recordClass:DNSRecordClassIN];
        PDebug(@"Getting DNSKEY keys for %@", dnskeyQuestion.name);
        DNSMessage * dnskeyMessage = [DNSMessage new];
        dnskeyMessage.idNumber = arc4random_uniform(UINT16_MAX);
        dnskeyMessage.dnssecOK = true;
        dnskeyMessage.questions = @[dnskeyQuestion];
        int __block index = i;
        [client sendMessage:dnskeyMessage gotReply:^(DNSMessage * reply, NSError * error) {
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
                BOOL hasDNSKEY = false;
                BOOL hasRRSIG = false;
                for (DNSAnswer * answer in reply.answers) {
                    switch (answer.recordType) {
                        case DNSRecordTypeRRSIG: {
                            hasRRSIG = true;
                            break;
                        } case DNSRecordTypeDNSKEY: {
                            hasDNSKEY = true;
                            break;
                        } default:
                            break;
                    }
                }

                @synchronized (lock) {
                    if (!hasDNSKEY || !hasRRSIG) {
                        NSString * errorDescription = [NSString stringWithFormat:@"No DNSKEY or RRSIG record for %@", reply.questions[0].name];
                        [dnskeyErrors insertObject:MAKE_ERROR(-1, errorDescription) atIndex:index];
                    } else {
                        [dnskeys insertObject:reply.answers atIndex:index];
                    }
                }
            }

            @synchronized (lock) {
                questionsAnswered++;
                if (questionsAnswered >= questionsToSend) {
                    dispatch_semaphore_signal(sync);
                }
            }
        }];

        // Root zone does not have a DS (obviously)
        if (names[i].length == 1 && [names[i] characterAtIndex:0] == '.') {
            @synchronized (lock) {
                questionsAnswered++;
                if (questionsAnswered >= questionsToSend) {
                    dispatch_semaphore_signal(sync);
                }
            }
            continue;
        }

        // Get the DS record for this zone
        DNSQuestion * dsQuestion = [[DNSQuestion alloc] initWithName:names[i] recordType:DNSRecordTypeDS recordClass:DNSRecordClassIN];
        PDebug(@"Getting DS records for %@", dsQuestion.name);
        DNSMessage * dsMessage = [DNSMessage new];
        dsMessage.idNumber = arc4random_uniform(UINT16_MAX);
        dsMessage.dnssecOK = true;
        dsMessage.questions = @[dsQuestion];
        [client sendMessage:dsMessage gotReply:^(DNSMessage * reply, NSError * error) {
            if (error != nil) {
                @synchronized (lock) {
                    [dsErrors insertObject:error atIndex:index];
                }
            } else if (reply.responseCode != DNSResponseCodeSuccess) {
                @synchronized (lock) {
                    NSString * errorDescription = [NSString stringWithFormat:@"No DS record for %@", reply.questions[0].name];
                    [dsErrors insertObject:MAKE_ERROR(-1, errorDescription) atIndex:index];
                }
            } else {
                BOOL hasDS = false;
                BOOL hasRRSIG = false;
                for (DNSAnswer * answer in reply.answers) {
                    switch (answer.recordType) {
                        case DNSRecordTypeRRSIG: {
                            hasRRSIG = true;
                            break;
                        } case DNSRecordTypeDS: {
                            hasDS = true;
                            break;
                        } default:
                            break;
                    }
                }

                @synchronized (lock) {
                    if (!hasDS || !hasRRSIG) {
                        NSString * errorDescription = [NSString stringWithFormat:@"No DS or RRSIG record for %@", reply.questions[0].name];
                        [dsErrors insertObject:MAKE_ERROR(-1, errorDescription) atIndex:index];
                    } else {
                        [dss insertObject:reply.answers atIndex:index];
                    }
                }
            }

            @synchronized (lock) {
                questionsAnswered++;
                if (questionsAnswered >= questionsToSend) {
                    dispatch_semaphore_signal(sync);
                }
            }
        }];
    }

    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));

    if (questionsAnswered != questionsToSend) {
        PError(@"Unable to query for all records in domain");
        *error = MAKE_ERROR(DNSSECErrorMissingKeys, @"One or more DNSKEY or DS records not found");
        return nil;
    }

    NSMutableArray<DNSSECResource *> * resources = [NSMutableArray arrayWithCapacity:names.count];

    // Sort through the answers and split up the DNSKEY, the RRSIG for the DNSKEY, and the same for the DS
    for (int i = 0; i < names.count; i++) {
        DNSSECResource * resource = [DNSSECResource new];
        resource.name = names[i];

        NSMutableArray * keys = [NSMutableArray new];
        for (DNSAnswer * answer in dnskeys[i]) {
            if (answer.recordType == DNSRecordTypeDNSKEY) {
                [keys addObject:answer];
            } else if (answer.recordType == DNSRecordTypeRRSIG) {
                resource.keySigs = answer;
            }
        }
        resource.dnsKeys = keys;

        if (names[i].length > 1) {
            for (DNSAnswer * answer in dss[i]) {
                if (answer.recordType == DNSRecordTypeDS) {
                    resource.ds = answer;
                } else if (answer.recordType == DNSRecordTypeRRSIG) {
                    resource.dsSigs = answer;
                }
            }
        }

        [resources insertObject:resource atIndex:i];
    }

    PInfo(@"Fetched keys and ds for %i zones", (int)names.count);
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

    // Sort the answers based on their record data
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
        [signeddata appendData:[answer rawSignatureData:rrsigAnswer]];
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
