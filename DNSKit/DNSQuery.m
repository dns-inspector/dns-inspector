#import "DNSQuery.h"

@interface DNSQuery ()

@property (strong, nonatomic) dispatch_queue_t queryQueue;

@end

@implementation DNSQuery

+ (DNSQuery *) queryWithServerType:(DNSServerType)serverType serverAddress:(NSString *)serverAddress recordType:(DNSRecordType)recordType name:(NSString *)name error:(NSError * _Nullable * _Nonnull)error {
    DNSQuery * query = [DNSQuery new];
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
