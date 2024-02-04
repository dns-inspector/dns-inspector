#import "DNSARecordData.h"
#import "DNSRecordData+Private.h"
#import <arpa/inet.h>

@implementation DNSARecordData

- (NSString *) ipAddress {
    int addrlen = INET_ADDRSTRLEN;
    int af = AF_INET;
    char * addr = malloc(addrlen);
    inet_ntop(af, self.recordValue.bytes, addr, addrlen);
    return [NSString stringWithFormat:@"%s", addr];
}

- (NSString *) stringValue {
    return [self ipAddress];
}

@end
