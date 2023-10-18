#import "DNSQuery.h"
#import "DNSServer.h"
#import "DNSServerDNS.h"
#import "DNSServerHTTPS.h"
#import "DNSServerTLS.h"

@interface DNSQuery ()

@property (strong, nonatomic) DNSServer * dnsServer;
@property (strong, nonatomic) dispatch_queue_t queryQueue;

@end

@implementation DNSQuery

+ (DNSQuery *) queryWithServerType:(DNSServerType)serverType serverAddress:(NSString *)serverAddress recordType:(DNSRecordType)recordType name:(NSString *)name error:(NSError * _Nullable * _Nonnull)error {
    DNSServer * server;
    NSError * serverError;
    switch (serverType) {
        case DNSServerTypeDNS: {
            server = [DNSServerDNS serverWithAddress:serverAddress error:&serverError];
            break;
        }
        case DNSServerTypeHTTPS: {
            server = [DNSServerHTTPS serverWithAddress:serverAddress error:&serverError];
            break;
        }
        case DNSServerTypeTLS: {
            server = [DNSServerTLS serverWithAddress:serverAddress error:&serverError];
            break;
        }
        default: {
            break;
        }
    }
    if (serverError != nil) {
        *error = serverError;
        return nil;
    }

    DNSQuery * query = [DNSQuery new];
    query.dnsServer = server;
    query.recordType = recordType;
    query.name = name;
    query.queryQueue = dispatch_queue_create("io.ecn.DNSKit.DNSQuery", 0);
    return query;
}

- (void) execute:(void (^)(DNSMessage *, NSError *))completed {
    dispatch_async(self.queryQueue, ^{
        sleep(2);
        completed([DNSMessage new], nil);
    });
}

@end
