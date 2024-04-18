#import <Foundation/Foundation.h>
#import "DNSAnswer.h"
#import "DNSRRSIGRecordData.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSAnswer (Private)

- (NSData *) rawSignatureData:(DNSRRSIGRecordData *)rrsig;

@end

NS_ASSUME_NONNULL_END
