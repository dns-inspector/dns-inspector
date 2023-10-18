#import "DNSServerTLS.h"

@implementation DNSServerTLS

+ (DNSServer *) serverWithAddress:(NSString *)address error:(NSError **)error {
    DNSServerTLS * dns = [DNSServerTLS new];
    return dns;
}

- (void) execute:(void (^)(DNSMessage *, NSError *))completed {

}

@end
