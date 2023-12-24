#import <XCTest/XCTest.h>
#import "DNSKitTests.h"
@import DNSKit;
#import "../DNSKit/IPAddressParser.h"

@interface IPAddressParserTests : XCTestCase

@end

@implementation IPAddressParserTests

#define TEST_TIMEOUT 10 // Seconds

- (void) setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) testIPv4 {
    IPAddressParser * parser = [IPAddressParser new];
    NSError * error = [parser parseString:@"127.0.0.1"];
    XCTAssertNil(error);
    XCTAssertStringEqual(parser.ipAddress, @"127.0.0.1");
    XCTAssertEqual(parser.version, IPAddressVersion4);
}

- (void) testInvalidIPv4 {
    IPAddressParser * parser = [IPAddressParser new];
    NSError * error = [parser parseString:@"256.0.0.1"];
    XCTAssertNotNil(error);
}

- (void) testIPv4WithPort {
    IPAddressParser * parser = [IPAddressParser new];
    NSError * error = [parser parseString:@"127.0.0.1:80"];
    XCTAssertNil(error);
    XCTAssertStringEqual(parser.ipAddress, @"127.0.0.1");
    XCTAssertEqual(parser.version, IPAddressVersion4);
    XCTAssertEqual(parser.port, (UInt16)80);
}

- (void) testInvalidIPv4WithPort {
    IPAddressParser * parser = [IPAddressParser new];
    NSError * error = [parser parseString:@"256.0.0.1:80"];
    XCTAssertNotNil(error);
}

- (void) testIPv4WithInvalidPort {
    IPAddressParser * parser = [IPAddressParser new];
    NSError * error = [parser parseString:@"127.0.0.1:65536"];
    XCTAssertNotNil(error);
}

- (void) testIPv6 {
    IPAddressParser * parser = [IPAddressParser new];
    NSError * error = [parser parseString:@"fe80::1"];
    XCTAssertNil(error);
    XCTAssertStringEqual(parser.ipAddress, @"fe80::1");
    XCTAssertEqual(parser.version, IPAddressVersion6);
}

- (void) testInvalidIPv6 {
    IPAddressParser * parser = [IPAddressParser new];
    NSError * error = [parser parseString:@"fffff::1"];
    XCTAssertNotNil(error);
}

- (void) testIPv6WithPort {
    IPAddressParser * parser = [IPAddressParser new];
    NSError * error = [parser parseString:@"[fe80::1]:80"];
    XCTAssertNil(error);
    XCTAssertStringEqual(parser.ipAddress, @"fe80::1");
    XCTAssertEqual(parser.version, IPAddressVersion6);
    XCTAssertEqual(parser.port, (UInt16)80);
}

- (void) testInvalidIPv6WithPort {
    IPAddressParser * parser = [IPAddressParser new];
    NSError * error = [parser parseString:@"[fe80:car::1]:80"];
    XCTAssertNotNil(error);
}

- (void) testIPv6WithInvalidPort {
    IPAddressParser * parser = [IPAddressParser new];
    NSError * error = [parser parseString:@"[fe80::1]:65536"];
    XCTAssertNotNil(error);
}

@end
