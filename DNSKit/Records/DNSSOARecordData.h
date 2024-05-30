#import <DNSKit/DNSKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSSOARecordData : DNSRecordData

@property (nonatomic, strong, nonnull, readonly) NSString * mname;
@property (nonatomic, strong, nonnull, readonly) NSString * rname;
@property (nonatomic) NSUInteger serial;
@property (nonatomic) NSInteger refresh;
@property (nonatomic) NSInteger retry;
@property (nonatomic) NSInteger expire;
@property (nonatomic) NSUInteger minimum;

@end

NS_ASSUME_NONNULL_END
