#import <Foundation/Foundation.h>
#import <DNSKit/DNSRecordData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSAAAARecordData : DNSRecordData

@property (strong, nonatomic, nullable, readonly) NSString * ipAddress;

@end

NS_ASSUME_NONNULL_END
