#import <XCTest/XCTest.h>
#import "DNSKitTests.h"
@import DNSKit;
#import "../DNSKit/DNSClientTLS.h"
#import "DNSClientTests.h"

@interface DNSClientTLSTests : XCTestCase

@end

@implementation DNSClientTLSTests

#define TEST_TIMEOUT 10 // Seconds

- (void) setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) testQueryA {
    NSError * clientError;
    DNSClientTLS * client = (DNSClientTLS *)[DNSClientTLS serverWithAddress:@"8.8.8.8" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }

    [[DNSClientTests fixtureWithClientType:DNSClientTypeTLS client:client] testQueryA];
}

- (void) testQueryAAAA {
    NSError * clientError;
    DNSClientTLS * client = (DNSClientTLS *)[DNSClientTLS serverWithAddress:@"8.8.8.8" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }

    [[DNSClientTests fixtureWithClientType:DNSClientTypeTLS client:client] testQueryAAAA];
}

- (void) testQueryNXDOMAIN {
    NSError * clientError;
    DNSClientTLS * client = (DNSClientTLS *)[DNSClientTLS serverWithAddress:@"8.8.8.8" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }

    [[DNSClientTests fixtureWithClientType:DNSClientTypeTLS client:client] testQueryNXDOMAIN];
}

- (void) testTimeout {
    NSError * clientError;
    DNSClientTLS * client = (DNSClientTLS *)[DNSClientTLS serverWithAddress:@"127.0.0.1" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }

    [[DNSClientTests fixtureWithClientType:DNSClientTypeTLS client:client] testQueryTimeout];
}


@end
