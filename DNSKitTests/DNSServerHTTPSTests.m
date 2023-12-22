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
        XCTAssertNil(error);
        XCTAssertNotNil(message);
        XCTAssertTrue(message.answers.count > 0);
        XCTAssertEqual(message.responseCode, DNSResponseCodeSuccess);

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

- (void) testAAAAQuery {
    NSError * managerError;
    DNSServerHTTPS * manager = (DNSServerHTTPS *)[DNSServerHTTPS serverWithAddress:@"https://dns.google/dns-query" error:&managerError];
    if (managerError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }

    NSError * queryError;
    DNSQuery * query = [DNSQuery queryWithServerType:DNSServerTypeHTTPS serverAddress:@"" recordType:DNSRecordTypeAAAA name:@"dns.google" error:&queryError];

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;

    [manager sendMessage:[query dnsMessage] gotReply:^(DNSMessage * message, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(message);
        XCTAssertTrue(message.answers.count > 0);
        XCTAssertEqual(message.responseCode, DNSResponseCodeSuccess);

        for (DNSAnswer * answer in message.answers) {
            DNSARecordData * data = (DNSARecordData *)answer.data;
            XCTAssertTrue([[data ipAddress] isEqualToString:@"2001:4860:4860::8888"] || [[data ipAddress] isEqualToString:@"2001:4860:4860::8844"]);
        }

        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testNXDomain {
    NSError * managerError;
    DNSServerHTTPS * manager = (DNSServerHTTPS *)[DNSServerHTTPS serverWithAddress:@"https://dns.google/dns-query" error:&managerError];
    if (managerError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }

    NSError * queryError;
    DNSQuery * query = [DNSQuery queryWithServerType:DNSServerTypeHTTPS serverAddress:@"" recordType:DNSRecordTypeA name:@"if-you-register-this-domain-im-going-to-be-very-angry.com" error:&queryError];

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;

    [manager sendMessage:[query dnsMessage] gotReply:^(DNSMessage * message, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(message);
        XCTAssertTrue(message.answers.count == 0);
        XCTAssertEqual(message.responseCode, DNSResponseCodeNXDOMAIN);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testTimeout {
    NSError * managerError;
    DNSServerHTTPS * manager = (DNSServerHTTPS *)[DNSServerHTTPS serverWithAddress:@"https://127.1.1.1/dns-query" error:&managerError];
    if (managerError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }

    NSError * queryError;
    DNSQuery * query = [DNSQuery queryWithServerType:DNSServerTypeHTTPS serverAddress:@"" recordType:DNSRecordTypeA name:@"just-a-test.com" error:&queryError];

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;

    [manager sendMessage:[query dnsMessage] gotReply:^(DNSMessage * message, NSError * error) {
        XCTAssertNotNil(error);
        XCTAssertStringEqual(error.localizedDescription, @"The request timed out.");
        XCTAssertTrue(message.answers.count == 0);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)((TEST_TIMEOUT * 3) * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testBadServerURL {
    NSError * managerError;
    DNSServerHTTPS * manager;

    manager = (DNSServerHTTPS *)[DNSServerHTTPS serverWithAddress:@"ftp://127.1.1.1/dns-query" error:&managerError];
    XCTAssertNotNil(managerError);
    XCTAssertNil(manager);

    manager = (DNSServerHTTPS *)[DNSServerHTTPS serverWithAddress:@"" error:&managerError];
    XCTAssertNotNil(managerError);
    XCTAssertNil(manager);
}

@end
