#import <DNSKit/DNSKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSDSRecordData : DNSRecordData

@property (nonatomic, readonly) NSUInteger keyTag;
@property (nonatomic, readonly) DNSSECAlgorithm algorithmType;
@property (nonatomic, readonly) DNSSECDigest digestType;
@property (strong, nonatomic, nonnull, readonly) NSData * digest;

@end

NS_ASSUME_NONNULL_END
