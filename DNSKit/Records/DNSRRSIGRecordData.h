#import <Foundation/Foundation.h>
#import <DNSKit/DNSRecordData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSRRSIGRecordData : DNSRecordData

@property (nonatomic, readonly) DNSRecordType typeCovered;
@property (nonatomic, readonly) DNSSECAlgorithm algorithm;
@property (nonatomic, readonly) NSUInteger labelCount;
@property (nonatomic, readonly) NSUInteger ttlSeconds;
@property (strong, nonatomic, readonly, nonnull) NSDate * signatureNotAfter;
@property (strong, nonatomic, readonly, nonnull) NSDate * signatureNotBefore;
@property (nonatomic, readonly) NSUInteger keyTag;
@property (strong, nonatomic, readonly, nonnull) NSString * signerName;
@property (strong, nonatomic, readonly, nonnull) NSData * signature;

- (NSData * __nonnull) signedData;

@end

NS_ASSUME_NONNULL_END
