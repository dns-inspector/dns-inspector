#import <XCTest/XCTest.h>
@import DNSKit;
#import "DNSKitTests.h"

@interface WHOISClientTests : XCTestCase

@end

@implementation WHOISClientTests

#define TEST_TIMEOUT 10 // Seconds

- (void) setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) testGetLookupHostForDomain {
    NSString * expected;
    NSString * actual;
    NSString * input;
    NSString * bare;

    input = @"example.com.";
    expected = @"whois.verisign-grs.com";
    actual = [WHOISClient getLookupHostForDomain:input bareDomain:&bare];
    XCTAssertStringEqual(actual, expected);
    XCTAssertStringEqual(bare, @"example.com");

    input = @"example.example.example.com";
    expected = @"whois.verisign-grs.com";
    actual = [WHOISClient getLookupHostForDomain:input bareDomain:&bare];
    XCTAssertStringEqual(actual, expected);
    XCTAssertStringEqual(bare, @"example.com");

    input = @"example.cn.com";
    expected = @"whois.centralnic.net";
    actual = [WHOISClient getLookupHostForDomain:input bareDomain:&bare];
    XCTAssertStringEqual(actual, expected);
    XCTAssertStringEqual(bare, @"example.cn.com");

    input = @"example.app";
    expected = @"whois.nic.app";
    actual = [WHOISClient getLookupHostForDomain:input bareDomain:&bare];
    XCTAssertStringEqual(actual, expected);
    XCTAssertStringEqual(bare, @"example.app");

    input = @"example.example.example.app";
    expected = @"whois.nic.app";
    actual = [WHOISClient getLookupHostForDomain:input bareDomain:&bare];
    XCTAssertStringEqual(actual, expected);
    XCTAssertStringEqual(bare, @"example.app");

    // lamo if somebody actually registers .acab as a gTLD
    XCTAssertNil([WHOISClient getLookupHostForDomain:@"blm.acab" bareDomain:&bare]);
}

- (void) testWHOISClient {
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;

    [WHOISClient lookupDomain:@"example.com" completed:^(NSString * response, NSError * error) {
        XCTAssertNotNil(response);
        XCTAssertNil(error);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];

    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

@end
