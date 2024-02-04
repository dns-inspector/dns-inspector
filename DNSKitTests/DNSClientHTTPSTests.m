#import <XCTest/XCTest.h>
#import "DNSKitTests.h"
@import DNSKit;
#import "../DNSKit/DNSClientHTTPS.h"
#import "DNSClientTests.h"

@interface DNSClientHTTPSTests : XCTestCase

@end

@implementation DNSClientHTTPSTests

#define TEST_TIMEOUT 10 // Seconds

- (void) setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) testQueryA {
    NSError * clientError;
    DNSClientHTTPS * client = (DNSClientHTTPS *)[DNSClientHTTPS serverWithAddress:@"https://dns.google/dns-query" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }

    [[DNSClientTests fixtureWithClientType:DNSClientTypeHTTPS client:client] testQueryA];
}

- (void) testQueryNS {
    NSError * clientError;
    DNSClientHTTPS * client = (DNSClientHTTPS *)[DNSClientHTTPS serverWithAddress:@"https://dns.google/dns-query" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }

    [[DNSClientTests fixtureWithClientType:DNSClientTypeHTTPS client:client] testQueryNS];
}

- (void) testQueryAAAA {
    NSError * clientError;
    DNSClientHTTPS * client = (DNSClientHTTPS *)[DNSClientHTTPS serverWithAddress:@"https://dns.google/dns-query" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }

    [[DNSClientTests fixtureWithClientType:DNSClientTypeHTTPS client:client] testQueryAAAA];
}

- (void) testQueryNXDOMAIN {
    NSError * clientError;
    DNSClientHTTPS * client = (DNSClientHTTPS *)[DNSClientHTTPS serverWithAddress:@"https://dns.google/dns-query" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }

    [[DNSClientTests fixtureWithClientType:DNSClientTypeHTTPS client:client] testQueryNXDOMAIN];
}

- (void) testTimeout {
    NSError * clientError;
    DNSClientHTTPS * client = (DNSClientHTTPS *)[DNSClientHTTPS serverWithAddress:@"https://127.0.0.1/dns-query" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }

    [[DNSClientTests fixtureWithClientType:DNSClientTypeHTTPS client:client] testQueryTimeout];
}


- (void) testBadServerURL {
    NSError * managerError;
    DNSClientHTTPS * manager;

    manager = (DNSClientHTTPS *)[DNSClientHTTPS serverWithAddress:@"ftp://127.1.1.1/dns-query" error:&managerError];
    XCTAssertNotNil(managerError);
    XCTAssertNil(manager);

    manager = (DNSClientHTTPS *)[DNSClientHTTPS serverWithAddress:@"" error:&managerError];
    XCTAssertNotNil(managerError);
    XCTAssertNil(manager);
}

@end
