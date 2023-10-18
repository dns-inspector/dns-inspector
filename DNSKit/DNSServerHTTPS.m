#import "DNSServerHTTPS.h"

@implementation DNSServerHTTPS

+ (DNSServer *) serverWithAddress:(NSString *)address error:(NSError **)error {
    DNSServerHTTPS * dns = [DNSServerHTTPS new];
    return dns;
}

- (void) execute:(void (^)(DNSMessage *, NSError *))completed {

}

@end
