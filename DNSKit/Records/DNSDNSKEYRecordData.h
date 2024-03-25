#import <DNSKit/DNSKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSDNSKEYRecordData : DNSRecordData

@property (nonatomic, readonly) bool zoneKey;
@property (nonatomic, readonly) bool revoked;
@property (nonatomic, readonly) bool zoneSigningKey;
@property (nonatomic, readonly) NSUInteger protocol;
@property (nonatomic, readonly) DNSSECAlgorithm algoritm;
@property (strong, nonatomic, nonnull, readonly) NSData * publicKey;

@end

NS_ASSUME_NONNULL_END
