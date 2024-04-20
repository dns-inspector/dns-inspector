#import "ASN1Utils.h"
#import "NSData+ByteAtIndex.h"

@implementation ASN1Utils

+ (NSData *) pkcs1RSAPubkey:(uint32_t)exponent exponentLength:(uint8_t)exponentLength modulus:(NSData *)modulus {
    // DNSSEC returns RSA keys as 1 or 3 bytes for the length of the exponent, then the remainder of the bytes for the
    // modulus. Apple expects RSA keys to be a ASN.1 sequence of the modulus then the exponent.
    //
    // For the exponent length, if the first byte is 0 then the next two bytes are the length of the exponnet. Howevever,
    // DNS Inspector does not support exponents greater than 4 bytes - which will always fit within 1 byte for length.

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
        case DNSSECAlgorithmRSA_SHA1:
        case DNSSECAlgorithmRSA_SHA256:
        case DNSSECAlgorithmRSA_SHA512: {
            // No need to do any transformation
            return signature;
        }
        case DNSSECAlgorithmECDSAP256_SHA256:
        case DNSSECAlgorithmECDSAP384_SHA384: {
            // DNSSEC returns the bare R and S coords concationated together
            // but Apple expects it to be in a ASN.1 sequence.

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
