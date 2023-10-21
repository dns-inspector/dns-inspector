#import "DNSServerDNS.h"

@implementation DNSServerDNS

+ (DNSServer *) serverWithAddress:(NSString *)address error:(NSError **)error {
    DNSServerDNS * dns = [DNSServerDNS new];
    return dns;
}

- (void) sendMessage:(DNSMessage *)message gotReply:(void (^)(DNSMessage *, NSError *))completed {

}

@end
