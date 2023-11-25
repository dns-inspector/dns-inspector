#import <XCTest/XCTest.h>
#import "DNSKitTests.h"
#import "../DNSKit/Extensions/NSData+Base64URL.h"
#import "../DNSKit/Extensions/NSData+HexString.h"
#import "../DNSKit/Extensions/NSData+ByteAtIndex.h"

@interface NSDataFormatTests : XCTestCase

@end

@implementation NSDataFormatTests

- (void) setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) testNSDataBase64URL {
    NSString * base64URLValue = [[@"Hello, world!" dataUsingEncoding:NSASCIIStringEncoding] base64URLEncodedValue];
    XCTAssertStringEqual(base64URLValue, @"SGVsbG8sIHdvcmxkIQ");
}

- (void) testNSDataHexString {
    NSString * hexString = [[@"Hello, world!" dataUsingEncoding:NSASCIIStringEncoding] hexString];
    XCTAssertStringEqual(hexString, @"48656c6c6f2c20776f726c6421");
}

- (void) testNSDataByteAtIndex {
    NSData * stringData = [@"Hello, world!" dataUsingEncoding:NSASCIIStringEncoding];

    char b = [stringData byteAtIndex:0];
    XCTAssertTrue(b == 'H');
}

@end
