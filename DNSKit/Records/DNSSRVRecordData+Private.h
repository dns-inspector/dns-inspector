#import <Foundation/Foundation.h>
#import "DNSSRVRecordData.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSSRVRecordData (Private)

- (id) initWithPriority:(NSNumber *)priority weight:(NSNumber *)weight port:(NSNumber *)port name:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
