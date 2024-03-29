#import <XCTest/XCTest.h>
#import "DNSKitTests.h"
#import "../DNSKit/Extensions/NSArray+Subindex.h"
#import "../DNSKit/Extensions/NSData+Base64URL.h"
#import "../DNSKit/Extensions/NSData+ByteAtIndex.h"
#import "../DNSKit/Extensions/NSData+HexString.h"

@interface ExtensionsTests : XCTestCase

@end

@implementation ExtensionsTests

#define TEST_TIMEOUT 10 // Seconds

- (void) setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) testSubarray {
    NSArray<NSString *> * arr = @[@"all", @"cops", @"are", @"bastards"];

    XCTAssertStringEqual([[arr subarrayToIndex:2] componentsJoinedByString:@" "], @"all cops");
    XCTAssertStringEqual([[arr subarrayFromIndex:2] componentsJoinedByString:@" "], @"are bastards");
}

- (void) testBase64EncodedValue {
    uint8_t dataLiteral[] = { 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21 };
    NSData * data = [NSData dataWithBytes:dataLiteral length:12];
    NSString * base64 = [data base64EncodedStringWithOptions:0];
    XCTAssertStringEqual(base64, @"SGVsbG8gd29ybGQh");
    NSString * base64URL = [data base64URLEncodedValue];
    XCTAssertStringEqual(base64URL, @"SGVsbG8gd29ybGQh");
}

- (void) testByteAtIndex {
    uint8_t dataLiteral[] = { 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21 };
    NSData * data = [NSData dataWithBytes:dataLiteral length:12];

    for (int i = 0; i < 12; i++) {
        uint8_t actual = dataLiteral[i];
        uint8_t byte = [data byteAtIndex:i];

        XCTAssertEqual(actual, byte);
    }
}

- (void) testHexString {
    uint8_t dataLiteral[] = { 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21 };
    NSData * data = [NSData dataWithBytes:dataLiteral length:12];
    NSString * hex = [data hexString];
    XCTAssertStringEqual(hex, @"48656c6c6f20776f726c6421");
}

@end
