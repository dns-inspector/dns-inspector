#import "IPAddressParser.h"
#import <arpa/inet.h>

@implementation IPAddressParser

- (NSError *) parseString:(NSString *)ipAddressString {
    /*
     * Acceppted IP address formats:
     *
     * IPv4:
     * - n.n.n.n
     * - n.n.n.n:p
     *
     * IPv6:
     * - x::
     * - [x::]:p
     */

    NSRegularExpression * portSuffixPattern = [NSRegularExpression regularExpressionWithPattern:@"\\]?:\\d{1,5}$" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression * ipv4Pattern = [NSRegularExpression regularExpressionWithPattern:@"^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}(\\:[0-9]{1,5})?$" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression * ipv6Pattern = [NSRegularExpression regularExpressionWithPattern:@"^\\[?(([0-9a-f\\:]+){1,4}){1,8}\\]?(\\:[0-9]{1,5})?$" options:NSRegularExpressionCaseInsensitive error:nil];

    if ([ipv4Pattern matchesInString:ipAddressString options:0 range:NSMakeRange(0, ipAddressString.length)].count > 0) {
        NSString * ipAddress;

        // Check for port suffix
        NSArray<NSTextCheckingResult *> * portMatches = [portSuffixPattern matchesInString:ipAddressString options:0 range:NSMakeRange(0, ipAddressString.length)];
        if (portMatches.count == 1) {
            NSString * portStr = [ipAddressString substringWithRange:NSMakeRange(portMatches[0].range.location+1, portMatches[0].range.length-1)];
            ipAddress = [ipAddressString substringToIndex:portMatches[0].range.location];

            NSInteger portInt = [portStr integerValue];
            if (portInt <= 0 || portInt > 65535) {
                // Invalid port
                return MAKE_ERROR(-1, @"Invalid port number");
            }

            self.port = (UInt16)portInt;
        } else {
            ipAddress = ipAddressString;
        }

        struct sockaddr_in sa;
        if (inet_pton(AF_INET, [ipAddress UTF8String], &(sa.sin_addr)) == 0) {
            // Invalid IP address
            return MAKE_ERROR(-1, @"Invalid IP address");
        }

        self.ipAddress = ipAddress;
        self.version = IPAddressVersion4;

        return nil;
    } else if ([ipv6Pattern matchesInString:ipAddressString options:0 range:NSMakeRange(0, ipAddressString.length)].count > 0) {
        NSString * ipAddress;

        // Check for port suffix. IPv6 addresses must be wrapped with [] when a port is specified
        NSArray<NSTextCheckingResult *> * portMatches = [portSuffixPattern matchesInString:ipAddressString options:0 range:NSMakeRange(0, ipAddressString.length)];
        if ([ipAddressString characterAtIndex:0] == '[' && portMatches.count == 1) {
            NSString * portStr = [ipAddressString substringWithRange:NSMakeRange(portMatches[0].range.location+2, portMatches[0].range.length-2)];
            ipAddress = [ipAddressString substringWithRange:NSMakeRange(1, portMatches[0].range.location-1)];

            NSInteger portInt = [portStr integerValue];
            if (portInt <= 0 || portInt > 65535) {
                // Invalid port
                return MAKE_ERROR(-1, @"Invalid port number");
            }

            self.port = (UInt16)portInt;
        } else {
            ipAddress = ipAddressString;
        }

        struct sockaddr_in6 sa;
        if (inet_pton(AF_INET6, [ipAddress UTF8String], &(sa.sin6_addr)) == 0) {
            // Invalid IP address
            return MAKE_ERROR(-1, @"Invalid IP address");
        }

        self.ipAddress = ipAddress;
        self.version = IPAddressVersion6;

        return nil;
    }

    return MAKE_ERROR(-2, @"Unknown IP address format");
}

@end
