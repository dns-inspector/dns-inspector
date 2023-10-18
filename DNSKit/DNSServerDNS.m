#import "DNSServerDNS.h"

@implementation DNSServerDNS

+ (DNSServer *) serverWithAddress:(NSString *)address error:(NSError **)error {
    DNSServerDNS * dns = [DNSServerDNS new];
    return dns;
}

- (void) execute:(void (^)(DNSMessage *, NSError *))completed {

}

@end
