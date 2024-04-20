#import <Foundation/Foundation.h>
#import "DNSAnswer.h"
#import "DNSRRSIGRecordData.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSAnswer (Private)

/// Return the raw data for a signature associated with a given rrsig answer
/// - Parameter rrsigAnswer: A RRSIG type DNS answer
- (NSData *) rawSignatureData:(DNSAnswer *)rrsigAnswer;

@end

NS_ASSUME_NONNULL_END
