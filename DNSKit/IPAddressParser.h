#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IPAddressParser : NSObject

typedef NS_ENUM(NSUInteger, IPAddressVersion) {
    IPAddressVersion4 = 4,
    IPAddressVersion6 = 6
};

/// The parsed IP address. May be either IPv4 or IPv6 and will never contain a port.
@property (strong, nonatomic, nonnull) NSString * ipAddress;

/// The port number from the parsed IP address, or 0 if no port number was specified.
@property (nonatomic) UInt16 port;

/// The IP address version of the parsed address.
@property (nonatomic) IPAddressVersion version;

/// Parse the given IP address and capture its properties in this parser instance.
/// Supports IPv4 address with and without a port suffix, IPv6 addresses without a port suffix, and wrapped IPv6 addresses with a port suffix.
/// IP addresses and port numbers are valided.
- (NSError * _Nullable) parseString:(NSString * _Nonnull)ipAddressString;

@end

NS_ASSUME_NONNULL_END
