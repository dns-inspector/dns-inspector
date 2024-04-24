#import "DNSDNSKEYRecordData.h"
#import "DNSRecordData+Private.h"
#import "DNSDNSKEYRecordData+Private.h"
#import "NSData+ByteAtIndex.h"
#import "DNSName.h"
#import "ASN1Utils.h"
#import <CommonCrypto/CommonCrypto.h>

@interface DNSDNSKEYRecordData ()

@property (nonatomic, readwrite) bool zoneKey;
@property (nonatomic, readwrite) bool revoked;
@property (nonatomic, readwrite) bool keySigningKey;
@property (nonatomic, readwrite) NSUInteger protocol;
@property (nonatomic, readwrite) DNSSECAlgorithm algoritm;
@property (strong, nonatomic, nonnull, readwrite) NSData * publicKey;

@end

@implementation DNSDNSKEYRecordData

#define MAX_RSA_EXP 2147483647

- (id) initWithRecordValue:(NSData *)value {
    self = [super initWithRecordValue:value];

    uint8_t flag1 = [self.recordValue byteAtIndex:0];
    uint8_t flag2 = [self.recordValue byteAtIndex:1];

    bool zoneKey = (flag1 & 0x01) > 0;
    bool revoked = (flag2 & 0x10) > 0;
    bool ksk = (flag2 & 0x01) > 0;

    uint8_t protocol = (uint8_t)[self.recordValue byteAtIndex:2];
    uint8_t algorithm = (uint8_t)[self.recordValue byteAtIndex:3];
    NSData * publicKey = [self.recordValue subdataWithRange:NSMakeRange(4, self.recordValue.length-4)];

    self.zoneKey = zoneKey;
    self.revoked = revoked;
    self.keySigningKey = ksk;
    self.protocol = protocol;
    self.algoritm = (DNSSECAlgorithm)algorithm;
    self.publicKey = publicKey;

    return self;
}

- (NSUInteger) keyTag {
    uint8_t * value = (uint8_t *)self.recordValue.bytes;

    unsigned long keytag = 0;

    for (int i = 0; i < self.recordValue.length; i++) {
        keytag += (i & 1) ? value[i] : value[i] << 8;
    }

    keytag += (keytag >> 16) & 0xFFFF;
    return keytag & 0xFFFF;
}

- (SecKeyRef) parsePublicKey:(NSError **)error {
    NSDictionary * keyAttributes;
    NSData * publicKey;

    switch (self.algoritm) {
        case DNSSECAlgorithmRSA_SHA256:
        case DNSSECAlgorithmRSA_SHA512:
        {
            keyAttributes = @{
                (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
                (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPublic,
            };

            if (self.publicKey.length < 1+1+64) {
                *error = MAKE_ERROR(DNSSECBadSigningKey, @"Invalid size of RSA key");
                return nil;
            }

            uint16_t exponentLength = 0;
            int exponentOffset = 1;

            // DNSKEY formats RSA keys as Exponent Length + Exponent + Modulus
            // Exponent length is either 1 or 3 bytes. If the first byte is 0, then the next two bytes are the length.
            if ((uint8_t)[self.publicKey byteAtIndex:0] == 0) {
                exponentLength = (uint16_t)[self.publicKey byteAtIndex:1]<<8 | (uint16_t)[self.publicKey byteAtIndex:2];
                exponentOffset = 3;
            } else {
                exponentLength = (uint16_t)[self.publicKey byteAtIndex:0];
            }

            // Bad or unsupported exponent length
            if (exponentLength > 4 || exponentLength == 0) {
                *error = MAKE_ERROR(DNSSECBadSigningKey, @"Invalid RSA key");
                return nil;
            }

            int modOffset = exponentOffset+exponentLength;
            uint32_t exponent = *(uint32_t *)[self.publicKey subdataWithRange:NSMakeRange(exponentOffset, exponentLength)].bytes;
            NSData * modulus = [self.publicKey subdataWithRange:NSMakeRange(modOffset, self.publicKey.length-modOffset)];

            // Apple needs the key to be in PKCS1 format, which is ASN.1 sequence of mod and exponent
            publicKey = [ASN1Utils pkcs1RSAPubkey:exponent exponentLength:(uint8_t)exponentLength modulus:modulus];

            break;
        }
        case DNSSECAlgorithmECDSAP256_SHA256:
        case DNSSECAlgorithmECDSAP384_SHA384:
        {
            keyAttributes = @{
                (id)kSecAttrKeyType: (id)kSecAttrKeyTypeEC,
                (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPublic,
            };

            // Apple needs EC public keys to have the uncompressed flag 0x04
            NSMutableData * pkey = [NSMutableData new];
            uint8_t flag = 0x04;
            [pkey appendBytes:&flag length:1];
            [pkey appendData:self.publicKey];
            publicKey = pkey;

            break;
        }
        default:
            break;
    }

    CFErrorRef keyError = NULL;
    SecKeyRef key = SecKeyCreateWithData((__bridge CFDataRef)publicKey, (__bridge CFDictionaryRef)keyAttributes, &keyError);
    if (!key) {
        NSError * e = CFBridgingRelease(keyError);
        *error = e;
        PError(@"Error creating internal public key from DNSKEY: %@", e.localizedDescription);
        return nil;
    }
    return key;
}

- (NSData *) hashWithOwnerName:(NSString *)ownerName algorithm:(DNSSECDigest)algorithm {
    NSMutableData * hashedData = [NSMutableData dataWithCapacity:ownerName.length+self.recordValue.length];
    [hashedData appendData:[DNSName stringToDNSName:ownerName error:nil]];
    [hashedData appendData:self.recordValue];

    switch (algorithm) {
        case DNSSECDigestSHA1: {
            unsigned char hash[CC_SHA1_DIGEST_LENGTH];
            if (CC_SHA1(hashedData.bytes, (CC_LONG)hashedData.length, hash)) {
                return [NSData dataWithBytes:hash length:CC_SHA1_DIGEST_LENGTH];
            }
            break;
        }
        case DNSSECDigestSHA256: {
            unsigned char hash[CC_SHA256_DIGEST_LENGTH];
            if (CC_SHA256(hashedData.bytes, (CC_LONG)hashedData.length, hash)) {
                return [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
            }
            break;
        }
        case DNSSECDigestSHA384: {
            unsigned char hash[CC_SHA384_DIGEST_LENGTH];
            if (CC_SHA384(hashedData.bytes, (CC_LONG)hashedData.length, hash)) {
                return [NSData dataWithBytes:hash length:CC_SHA384_DIGEST_LENGTH];
            }
            break;
        }
    }

    return nil;
}

- (NSString *) stringValue {
    uint16_t flags = ntohs(*(uint16_t*)[self.recordValue subdataWithRange:NSMakeRange(0, 2)].bytes);
    NSString * pubKey = [self.publicKey base64EncodedStringWithOptions:0];

    return [NSString stringWithFormat:@"%i %i %i %@", (int)flags, (int)self.protocol, (int)self.algoritm, pubKey];
}

@end
