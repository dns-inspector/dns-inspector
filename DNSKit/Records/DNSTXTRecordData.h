#import <Foundation/Foundation.h>
#import <DNSKit/DNSRecordData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSTXTRecordData : DNSRecordData

@property (strong, nonatomic, nullable, readonly) NSString * text;

@end

NS_ASSUME_NONNULL_END
