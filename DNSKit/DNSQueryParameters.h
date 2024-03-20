#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSQueryParameters : NSObject

/// If traditional DNS is used, should the request be sent over TCP.
/// If DNSSEC is being used this should be set to true.
@property (nonatomic) BOOL dnsPrefersTcp;

/// Should this query include a request for DNSSEC security records
@property (nonatomic) bool requestDNSSEC;

@end

NS_ASSUME_NONNULL_END
