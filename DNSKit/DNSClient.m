#import "DNSClient.h"

@implementation DNSClient
+ (DNSClient *) serverWithAddress:(NSString *)address error:(NSError **)error { assert("do not invoke directly"); return nil; }
- (void) sendMessage:(DNSMessage *)message gotReply:(void (^)(DNSMessage *, NSError *))completed { assert("do not invoke directly"); }
@end
