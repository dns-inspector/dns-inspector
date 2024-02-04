#import <XCTest/XCTest.h>
#import "DNSKitTests.h"
@import DNSKit;
#import "../DNSKit/DNSClientDNS.h"
#import "DNSClientTests.h"

@interface DNSClientDNSTests : XCTestCase

@end

@implementation DNSClientDNSTests

#define TEST_TIMEOUT 10 // Seconds

- (void) setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) testTCPQueryA {
    NSError * clientError;
    DNSClientDNS * client = (DNSClientDNS *)[DNSClientDNS serverWithAddress:@"8.8.8.8" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }
    client.useTCP = @true;

    [[DNSClientTests fixtureWithClientType:DNSClientTypeDNS client:client] testQueryA];
}

- (void) testTCPQueryNS {
    NSError * clientError;
    DNSClientDNS * client = (DNSClientDNS *)[DNSClientDNS serverWithAddress:@"8.8.8.8" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }
    client.useTCP = @true;

    [[DNSClientTests fixtureWithClientType:DNSClientTypeDNS client:client] testQueryNS];
}

- (void) testTCPQueryAAAA {
    NSError * clientError;
    DNSClientDNS * client = (DNSClientDNS *)[DNSClientDNS serverWithAddress:@"8.8.8.8" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }
    client.useTCP = @true;

    [[DNSClientTests fixtureWithClientType:DNSClientTypeDNS client:client] testQueryAAAA];
}

- (void) testTCPQueryNXDOMAIN {
    NSError * clientError;
    DNSClientDNS * client = (DNSClientDNS *)[DNSClientDNS serverWithAddress:@"8.8.8.8" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }
    client.useTCP = @true;

    [[DNSClientTests fixtureWithClientType:DNSClientTypeDNS client:client] testQueryNXDOMAIN];
}

- (void) testTCPTimeout {
    NSError * clientError;
    DNSClientDNS * client = (DNSClientDNS *)[DNSClientDNS serverWithAddress:@"127.0.0.1" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }
    client.useTCP = @true;

    [[DNSClientTests fixtureWithClientType:DNSClientTypeDNS client:client] testQueryTimeout];
}

- (void) testTCPRandomData {
    NSError * clientError;
    DNSClientDNS * client = (DNSClientDNS *)[DNSClientDNS serverWithAddress:@"127.0.0.1:8401" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }
    client.useTCP = @true;

    [[DNSClientTests fixtureWithClientType:DNSClientTypeDNS client:client] testRandomData];
}

- (void) testTCPLengthOver {
    NSError * clientError;
    DNSClientDNS * client = (DNSClientDNS *)[DNSClientDNS serverWithAddress:@"127.0.0.1:8401" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }
    client.useTCP = @true;

    [[DNSClientTests fixtureWithClientType:DNSClientTypeDNS client:client] testLengthOver];
}

- (void) testTCPLengthUnder {
    NSError * clientError;
    DNSClientDNS * client = (DNSClientDNS *)[DNSClientDNS serverWithAddress:@"127.0.0.1:8401" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }
    client.useTCP = @true;

    [[DNSClientTests fixtureWithClientType:DNSClientTypeDNS client:client] testLengthUnder];
}

- (void) testUDPQueryA {
    NSError * clientError;
    DNSClientDNS * client = (DNSClientDNS *)[DNSClientDNS serverWithAddress:@"8.8.8.8" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }
    client.useTCP = @false;

    [[DNSClientTests fixtureWithClientType:DNSClientTypeDNS client:client] testQueryA];
}

- (void) testUDPQueryAAAA {
    NSError * clientError;
    DNSClientDNS * client = (DNSClientDNS *)[DNSClientDNS serverWithAddress:@"8.8.8.8" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }
    client.useTCP = @false;

    [[DNSClientTests fixtureWithClientType:DNSClientTypeDNS client:client] testQueryAAAA];
}

- (void) testUDPQueryNXDOMAIN {
    NSError * clientError;
    DNSClientDNS * client = (DNSClientDNS *)[DNSClientDNS serverWithAddress:@"8.8.8.8" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }
    client.useTCP = @false;

    [[DNSClientTests fixtureWithClientType:DNSClientTypeDNS client:client] testQueryNXDOMAIN];
}

- (void) testUDPTimeout {
    NSError * clientError;
    DNSClientDNS * client = (DNSClientDNS *)[DNSClientDNS serverWithAddress:@"127.0.0.1" error:&clientError];
    if (clientError != nil) {
        XCTFail(@"Manager error should be nil");
        return;
    }
    client.useTCP = @false;

    [[DNSClientTests fixtureWithClientType:DNSClientTypeDNS client:client] testQueryTimeout];
}


@end
