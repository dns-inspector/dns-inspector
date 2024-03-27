#import <DNSKit/DNSKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSDNSKEYRecordData : DNSRecordData

@property (nonatomic, readonly) bool zoneKey;
@property (nonatomic, readonly) bool revoked;
@property (nonatomic, readonly) bool keySigningKey;
@property (nonatomic, readonly) NSUInteger protocol;
@property (nonatomic, readonly) DNSSECAlgorithm algoritm;
@property (strong, nonatomic, nonnull, readonly) NSData * publicKey;

- (NSUInteger) keyTag;

@end

NS_ASSUME_NONNULL_END
