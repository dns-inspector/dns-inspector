#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Describes DNSSEC related resources for a specific zone
@interface DNSSECResource : NSObject

@property (strong, nonatomic, nonnull) NSString * name;
@property (strong, nonatomic, nonnull) NSArray<DNSAnswer *> * dnsKeys;
@property (strong, nonatomic, nonnull) DNSAnswer * keySigs;
@property (strong, nonatomic, nullable) DNSAnswer * ds;
@property (strong, nonatomic, nullable) DNSAnswer * dsSigs;

@end

NS_ASSUME_NONNULL_END
