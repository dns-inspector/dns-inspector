#import "DNSQuery.h"
#import "DNSClient.h"
#import "DNSClient53UDP.h"
#import "DNSClient53TCP.h"
#import "DNSClientHTTPS.h"
#import "DNSClientTLS.h"
#import "DNSName.h"
#import "TypesInternal.h"

@interface DNSQuery ()

@property (nonatomic) NSUInteger idNumber;
@property (strong, nonatomic) DNSClient * dnsServer;
@property (strong, nonatomic) dispatch_queue_t queryQueue;

@end

@implementation DNSQuery

+ (DNSQuery *) queryWithClientType:(DNSClientType)clientType serverAddress:(NSString *)serverAddress recordType:(DNSRecordType)recordType name:(NSString *)name error:(NSError * _Nullable * _Nonnull)error {
    DNSClient * server;
    NSError * serverError;
    switch (clientType) {
        case DNSClientTypeUDP53: {
            server = [DNSClient53UDP serverWithAddress:serverAddress error:&serverError];
            break;
        }
        case DNSClientTypeTCP53: {
            server = [DNSClient53TCP serverWithAddress:serverAddress error:&serverError];
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
    dispatch_async(self.queryQueue, ^{
        [self.dnsServer sendMessage:[self dnsMessage] gotReply:^(DNSMessage * reply, NSError * error) {
            completed(reply, error);
        }];
    });
}

@end
