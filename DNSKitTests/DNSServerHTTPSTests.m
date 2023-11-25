#import <XCTest/XCTest.h>
#import "DNSKitTests.h"
@import DNSKit;
#import "../DNSKit/DNSServerHTTPS.h"

@interface DNSServerHTTPSTests : XCTestCase

@end

@implementation DNSServerHTTPSTests

#define TEST_TIMEOUT 10 // Seconds

- (void) setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) testAQuery {
    NSError * managerError;
    DNSServerHTTPS * manager = (DNSServerHTTPS *)[DNSServerHTTPS serverWithAddress:@"https://dns.google/dns-query" error:&managerError];
    if (managerError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }

    NSError * queryError;
    DNSQuery * query = [DNSQuery queryWithServerType:DNSServerTypeHTTPS serverAddress:@"" recordType:DNSRecordTypeA name:@"dns.google" error:&queryError];

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;

    [manager sendMessage:[query dnsMessage] gotReply:^(DNSMessage * message, NSError * error) {
        for (DNSAnswer * answer in message.answers) {
            DNSARecordData * data = (DNSARecordData *)answer.data;
            XCTAssertTrue([[data ipAddress] isEqualToString:@"8.8.8.8"] || [[data ipAddress] isEqualToString:@"8.8.4.4"]);
        }

        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

@end
