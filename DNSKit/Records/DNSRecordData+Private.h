#import <Foundation/Foundation.h>
#import "DNSRecordData.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSRecordData (Private)

- (id) initWithRecordValue:(NSData * _Nonnull)value;

@end

NS_ASSUME_NONNULL_END
