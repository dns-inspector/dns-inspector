#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WHOISClient : NSObject

/// Perform a WHOIS lookup on the given domain name
/// - Parameters:
///   - domain: The domain name without a trailing dot.
///   - completed: Called when the request has completed or an error occurec. Either the response or the error will not be nil.
+ (void) lookupDomain:(NSString * _Nonnull)domain completed:(void (^ _Nonnull)(NSString * _Nullable, NSError * _Nullable))completed;

/// Get the WHOIS server address for the given domain name. Returns nil if the TLD has no WHOIS server.
/// - Parameters:
///   - domain: The domain name to query for
///   - bareDomain: A pointer to an unallocated NSString object. This will be populated with the bare domain,
///                 that is the inputted domain with no subdomains.
+ (NSString * _Nullable) getLookupHostForDomain:(NSString * _Nonnull)domain bareDomain:(NSString * _Nullable * _Nonnull)bareDomain;

@end

NS_ASSUME_NONNULL_END
