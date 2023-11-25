#import <Foundation/Foundation.h>
#import "DNSMXRecordData.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSMXRecordData (Private)

- (id) initWithPriority:(NSNumber *)priority name:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
