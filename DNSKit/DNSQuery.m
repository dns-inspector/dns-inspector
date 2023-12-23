#import "DNSQuery.h"
#import "DNSClient.h"
#import "DNSClientDNS.h"
#import "DNSClientHTTPS.h"
#import "DNSClientTLS.h"
#import "DNSName.h"
#import "TypesInternal.h"
#import <mach/mach_time.h>

@interface DNSQuery ()

@property (nonatomic) NSUInteger idNumber;
@property (strong, nonatomic) DNSClient * dnsServer;
@property (strong, nonatomic) dispatch_queue_t queryQueue;

@end

@implementation DNSQuery

+ (DNSQuery *) queryWithClientType:(DNSClientType)clientType serverAddress:(NSString *)serverAddress recordType:(DNSRecordType)recordType name:(NSString *)name parameters:(DNSQueryParameters *)parameters error:(NSError **)error {
    DNSClient * server;
    NSError * serverError;
    switch (clientType) {
        case DNSClientTypeDNS: {
            bool useTcp = true;
            if (parameters != nil && !parameters.dnsPrefersTcp) {
                useTcp = false;
            }

            DNSClientDNS * dns = (DNSClientDNS *)[DNSClientDNS serverWithAddress:serverAddress error:&serverError];
            dns.useTCP = [NSNumber numberWithBool:useTcp];
            server = dns;
            break;
        }
        case DNSClientTypeHTTPS: {
            server = [DNSClientHTTPS serverWithAddress:serverAddress error:&serverError];
            break;
        }
        case DNSClientTypeTLS: {
            server = [DNSClientTLS serverWithAddress:serverAddress error:&serverError];
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
    query.idNumber = arc4random_uniform(UINT16_MAX);
    query.clientType = clientType;
    query.serverAddress = serverAddress;
    query.dnsServer = server;
    query.recordType = recordType;
    query.name = name;
    query.queryQueue = dispatch_queue_create("io.ecn.DNSKit.DNSQuery", 0);
    return query;
}

- (DNSMessage * _Nonnull) dnsMessage {
    DNSQuestion * question = [DNSQuestion new];
    question.name = self.name;
    question.recordType = self.recordType;
    question.recordClass = DNSRecordClassIN;

    DNSMessage * message = [DNSMessage new];
    message.idNumber = self.idNumber;
    message.questions = @[question];

    return message;
}

- (void) execute:(void (^)(DNSMessage *, NSError *))completed {
    dispatch_time_t start = mach_absolute_time();

    dispatch_async(self.queryQueue, ^{
        [self.dnsServer sendMessage:[self dnsMessage] gotReply:^(DNSMessage * reply, NSError * error) {
            dispatch_time_t end = mach_absolute_time();

            uint64_t elapsedTime = end - start;
            mach_timebase_info_data_t timebase;
            mach_timebase_info(&timebase);
            double ticksToNanoseconds = (double)timebase.numer / timebase.denom;
            double elapsedTimeInNanoseconds = elapsedTime * ticksToNanoseconds;
            reply.elapsedNs = [NSNumber numberWithDouble:elapsedTimeInNanoseconds];

            completed(reply, error);
        }];
    });
}

@end
