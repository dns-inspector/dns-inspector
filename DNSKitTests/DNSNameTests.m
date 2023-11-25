#import <XCTest/XCTest.h>
#import "DNSKitTests.h"
#import "../DNSKit/DNSName.h"
@import DNSKit;

@interface DNSNameTests : XCTestCase

@end

@implementation DNSNameTests

- (void) setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) testEncodeName {
    NSError * nameError;
    NSData * encodedName = [DNSName stringToDNSName:@"www.example.com" error:&nameError];
    XCTAssertNil(nameError);
    XCTAssertNotNil(encodedName);
}

- (void) testCatchEncodeInvalidName {
    NSError * nameError;
    NSData * encodedName = [DNSName stringToDNSName:@"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.example.com" error:&nameError];
    XCTAssertNotNil(nameError);
    XCTAssertNil(encodedName);
}

- (void) testReadUncompressedName {
    uint8_t nameLiteral[] = { 0x03, 0x64, 0x6e, 0x73, 0x06, 0x67, 0x6f, 0x6f, 0x67, 0x6c, 0x65, 0x00 };
    NSError * nameError;
    int dataIdx = 0;
    NSString * name = [DNSName readDNSName:[NSData dataWithBytes:nameLiteral length:12] startIndex:0 dataIndex:&dataIdx error:&nameError];
    XCTAssertNil(nameError);
    XCTAssertNotNil(name);
    XCTAssertStringEqual(name, @"dns.google.");
    XCTAssertEqual(dataIdx, 12);
}

- (void) testReadCompressedName {
    uint8_t nameLiteral[] = { 0x03, 0x64, 0x6e, 0x73, 0x06, 0x67, 0x6f, 0x6f, 0x67, 0x6c, 0x65, 0x00, 0xc0, 0x00 };
    NSError * nameError;
    int dataIdx = 0;
    NSString * name = [DNSName readDNSName:[NSData dataWithBytes:nameLiteral length:14] startIndex:12 dataIndex:&dataIdx error:&nameError];
    XCTAssertNil(nameError);
    XCTAssertNotNil(name);
    XCTAssertStringEqual(name, @"dns.google.");
    XCTAssertEqual(dataIdx, 14);
}

- (void) testCatchRecursiveCompressionPointer {
    uint8_t nameLiteral[] = { 0xc0, 0x00, 0xc0, 0x00 };
    NSError * nameError;
    int dataIdx = 0;
    NSString * name = [DNSName readDNSName:[NSData dataWithBytes:nameLiteral length:4] startIndex:2 dataIndex:&dataIdx error:&nameError];
    XCTAssertNotNil(nameError);
    XCTAssertNil(name);
}

- (void) testCatchInvalidCharactersInName {
    uint8_t nameLiteral[] = { 0x04, 0x64, 0x6e, 0x73, 0x2e, 0x06, 0x67, 0x6f, 0x6f, 0x67, 0x6c, 0x65, 0x00 };
    NSError * nameError;
    int dataIdx = 0;
    NSString * name = [DNSName readDNSName:[NSData dataWithBytes:nameLiteral length:13] startIndex:0 dataIndex:&dataIdx error:&nameError];
    XCTAssertNotNil(nameError);
    XCTAssertNil(name);
}

- (void) testCatchInvalidSegmentLength {
    uint8_t nameLiteral[] = { 0x03, 0x64, 0x6e, 0x73, 0x06, 0x67, 0x6f, 0x6f, 0x67, 0x6c, 0x65, 0x16 };
    NSError * nameError;
    int dataIdx = 0;
    NSString * name = [DNSName readDNSName:[NSData dataWithBytes:nameLiteral length:12] startIndex:0 dataIndex:&dataIdx error:&nameError];
    XCTAssertNotNil(nameError);
    XCTAssertNil(name);
}

- (void) testCatchInvalidPointerOffset {
    uint8_t nameLiteral[] = { 0xc0, 0x16 };
    NSError * nameError;
    int dataIdx = 0;
    NSString * name = [DNSName readDNSName:[NSData dataWithBytes:nameLiteral length:2] startIndex:0 dataIndex:&dataIdx error:&nameError];
    XCTAssertNotNil(nameError);
    XCTAssertNil(name);
}

- (void) testCatchInvalidPointerDestinationOffset {
    uint8_t nameLiteral[] = { 0xc0, 0x16, 0xc0, 0x00 };
    NSError * nameError;
    int dataIdx = 0;
    NSString * name = [DNSName readDNSName:[NSData dataWithBytes:nameLiteral length:4] startIndex:2 dataIndex:&dataIdx error:&nameError];
    XCTAssertNotNil(nameError);
    XCTAssertNil(name);
}

- (void) testCatchInvalidStartIndexUnderflow {
    uint8_t nameLiteral[] = { 0x03, 0x64, 0x6e, 0x73, 0x06, 0x67, 0x6f, 0x6f, 0x67, 0x6c, 0x65, 0x16 };
    NSError * nameError;
    int dataIdx = 0;
    NSString * name = [DNSName readDNSName:[NSData dataWithBytes:nameLiteral length:12] startIndex:-1 dataIndex:&dataIdx error:&nameError];
    XCTAssertNotNil(nameError);
    XCTAssertNil(name);
}

- (void) testCatchInvalidStartIndexOverflow {
    uint8_t nameLiteral[] = { 0x03, 0x64, 0x6e, 0x73, 0x06, 0x67, 0x6f, 0x6f, 0x67, 0x6c, 0x65, 0x16 };
    NSError * nameError;
    int dataIdx = 0;
    NSString * name = [DNSName readDNSName:[NSData dataWithBytes:nameLiteral length:12] startIndex:16 dataIndex:&dataIdx error:&nameError];
    XCTAssertNotNil(nameError);
    XCTAssertNil(name);
}

@end
