#import <Foundation/Foundation.h>
#import <DNSKit/DNSRecordData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSMXRecordData : DNSRecordData

@property (strong, nonatomic, nullable, readonly) NSNumber * priority;
@property (strong, nonatomic, nullable, readonly) NSString * name;

@end

NS_ASSUME_NONNULL_END
