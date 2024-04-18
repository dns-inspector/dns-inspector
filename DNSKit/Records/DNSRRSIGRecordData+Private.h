#import <Foundation/Foundation.h>
#import "DNSRRSIGRecordData.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSRRSIGRecordData (Private)

/// Returns a signature that is ready for use with Apple's common crypto
- (NSData * _Nonnull) signatureForCrypto;

@end

NS_ASSUME_NONNULL_END
