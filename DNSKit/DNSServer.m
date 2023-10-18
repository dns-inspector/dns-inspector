#import "DNSServer.h"

@implementation DNSServer

+ (DNSServer *) serverWithAddress:(NSString *)address error:(NSError **)error {
    return nil;
}

- (void) execute:(void (^)(DNSMessage *, NSError *))completed {

}

@end
