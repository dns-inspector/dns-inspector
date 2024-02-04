#import <Foundation/Foundation.h>
#import <DNSKit/DNSRecordData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSNSRecordData : DNSRecordData

@property (strong, nonatomic, nullable, readonly) NSString * name;

@end

NS_ASSUME_NONNULL_END
