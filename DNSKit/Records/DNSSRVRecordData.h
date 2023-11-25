#import <Foundation/Foundation.h>
#import "DNSRecordData.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSSRVRecordData : DNSRecordData

@property (strong, nonatomic, nullable, readonly) NSNumber * priority;
@property (strong, nonatomic, nullable, readonly) NSNumber * weight;
@property (strong, nonatomic, nullable, readonly) NSNumber * port;
@property (strong, nonatomic, nullable, readonly) NSString * name;

@end

NS_ASSUME_NONNULL_END
