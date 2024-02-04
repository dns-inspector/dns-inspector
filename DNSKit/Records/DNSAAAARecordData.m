#import "DNSAAAARecordData.h"
#import "DNSRecordData+Private.h"
#import <arpa/inet.h>

@implementation DNSAAAARecordData

- (NSString *) ipAddress {
    int addrlen = INET6_ADDRSTRLEN;
    int af = AF_INET6;
    char * addr = malloc(addrlen);
    inet_ntop(af, self.recordValue.bytes, addr, addrlen);
    return [NSString stringWithFormat:@"%s", addr];
}

- (NSString *) stringValue {
    return [self ipAddress];
}

@end
