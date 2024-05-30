#import <Foundation/Foundation.h>
#import "DNSSOARecordData.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSSOARecordData (Private)

+ (DNSSOARecordData *) readFromDNSMessage:(NSData *)data startingAt:(int)index error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
