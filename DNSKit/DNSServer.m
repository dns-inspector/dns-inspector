#import "DNSServer.h"

@implementation DNSServer

+ (DNSServer *) serverWithAddress:(NSString *)address error:(NSError **)error {
    return nil;
}

- (void) sendMessage:(DNSMessage *)message gotReply:(void (^)(DNSMessage *, NSError *))completed {

}

@end
