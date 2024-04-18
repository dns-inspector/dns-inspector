#import "ASN1Utils.h"
#import "NSData+ByteAtIndex.h"

@implementation ASN1Utils

+ (NSData *) pkcs1RSAPubkey:(uint32_t)exponent exponentLength:(uint8_t)exponentLength modulus:(NSData *)modulus {
    NSMutableData * paddedModulus;
    if (modulus.length == 256) {
        paddedModulus = [NSMutableData new];
        int p = 0;
        [paddedModulus appendBytes:&p length:1];
        [paddedModulus appendData:modulus];
    } else {
        paddedModulus = [NSMutableData dataWithData:modulus];
    }

    NSMutableData * publicKey = [NSMutableData new];
    uint8_t asn1Header[] = {
        0x30, // SEQUENCE
        0x82, // 2-byte length flag
    };
    [publicKey appendBytes:&asn1Header length:2];
    uint16_t seqLength = htons(4+paddedModulus.length+2+exponentLength);
    [publicKey appendBytes:&seqLength length:2];
    uint8_t modHeader[] = {
        0x02, // Integer
        0x82 // 2-byte length flag
    };
    [publicKey appendBytes:modHeader length:2];
    uint16_t modLengthBE = htons(paddedModulus.length);
    [publicKey appendBytes:&modLengthBE length:2];
    [publicKey appendData:paddedModulus];
    uint8_t expHeader[] = {
        0x02, // Integer
    };
    [publicKey appendBytes:expHeader length:1];
    [publicKey appendBytes:&exponentLength length:1];
    [publicKey appendBytes:&exponent length:exponentLength];

    return publicKey;
}

+ (NSData *) pkcs1Signature:(NSData *)signature algorithm:(DNSSECAlgorithm)algorithm {
    switch (algorithm) {
        case DNSSECAlgorithmECDSAP256_SHA256:
        case DNSSECAlgorithmECDSAP384_SHA384: {
            NSMutableData * r = [NSMutableData dataWithData:[signature subdataWithRange:NSMakeRange(0, signature.length/2)]];
            NSMutableData * s = [NSMutableData dataWithData:[signature subdataWithRange:NSMakeRange(r.length, signature.length-r.length)]];

            bool padR = false;
            bool padS = false;
            if (([r byteAtIndex:0]&0x80) != 0) {
                padR = true;
            }
            if (([s byteAtIndex:0]&0x80) != 0) {
                padS = true;
            }

            uint8_t padding = 0x00;

            NSMutableData * rSeq = [NSMutableData new];
            uint8_t rLength = r.length + (padR ? 1 : 0);
            uint8_t rheader[] = {
                0x02, // integer
                rLength,
            };
            [rSeq appendBytes:rheader length:2];
            if (padR) {
                [rSeq appendBytes:&padding length:1];
            }
            [rSeq appendData:r];

            NSMutableData * sSeq = [NSMutableData new];
            uint8_t sLength = s.length + (padS ? 1 : 0);
            uint8_t sheader[] = {
                0x02, // integer
                sLength,
            };
            [sSeq appendBytes:sheader length:2];
            if (padS) {
                [sSeq appendBytes:&padding length:1];
            }
            [sSeq appendData:s];

            NSMutableData * signature = [NSMutableData new];
            uint8_t header[] = {
                0x30, // sequence
                (uint8_t)rSeq.length+sSeq.length,
            };
            [signature appendBytes:header length:2];
            [signature appendData:rSeq];
            [signature appendData:sSeq];
            return signature;
        }
        default:
            return signature;
    }

    return nil;
}

@end
