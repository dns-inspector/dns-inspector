#import <Foundation/Foundation.h>
#import "Types.h"

NS_ASSUME_NONNULL_BEGIN

@interface ASN1Utils : NSObject

+ (NSData *) pkcs1RSAPubkey:(uint32_t)exponent exponentLength:(uint8_t)exponentLength modulus:(NSData *)modulus;
+ (NSData *) pkcs1Signature:(NSData *)signature algorithm:(DNSSECAlgorithm)algorithm;

@end

NS_ASSUME_NONNULL_END
