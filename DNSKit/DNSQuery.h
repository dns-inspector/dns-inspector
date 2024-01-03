#import <Foundation/Foundation.h>
#import <DNSKit/DNSKit.h>
#import <DNSKit/DNSQueryParameters.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSQuery : NSObject

/// The DNS client type
@property (nonatomic) DNSClientType clientType;

/// The address or url of the DNS server
@property (strong, nonatomic, nonnull) NSString * serverAddress;

/// The desired DNS record type
@property (nonatomic) DNSRecordType recordType;

/// The resource name of the query
@property (strong, nonatomic, nonnull) NSString * name;

/// The DNS message for this query
- (DNSMessage * _Nonnull) dnsMessage;

/// Prepare a DNS query
/// - Parameters:
///   - clientType: The DNS client type
///   - serverAddress: The address or url of the DNS server
///   - recordType: The desired DNS record type
///   - name: The resource name of the query
///   - parameters: Optional parameters for the request
///   - error: An error to populate with any name or client errors
/// - Returns: A DNS query that is validated and ready to be sent to the server.
+ (DNSQuery * _Nullable) queryWithClientType:(DNSClientType)clientType
                               serverAddress:(NSString * _Nonnull)serverAddress
                                  recordType:(DNSRecordType)recordType
                                        name:(NSString * _Nonnull)name
                                  parameters:(DNSQueryParameters * _Nullable)parameters
                                       error:(NSError * _Nullable * _Nonnull)error;

/// Perform this DNS query
/// - Parameter completed: called with either the DNS response or an error.
- (void) execute:(void (^_Nonnull)(DNSMessage * _Nullable, NSError * _Nullable))completed;

/// Validate the given DNS client configuration
/// - Parameters:
///   - clientType: The DNS client type
///   - serverAddress: The address or url of the DNS server
///   - parameters: Optional parameters for the request
/// - Returns: An error with a populated localized description, or nil if valid.
+ (NSError * _Nullable) validateDNSClientConfigurationWithClientType:(DNSClientType)clientType serverAddress:(NSString * _Nonnull)serverAddress parameters:(DNSQueryParameters * _Nullable)parameters;

@end

NS_ASSUME_NONNULL_END
