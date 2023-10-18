#import <XCTest/XCTest.h>
#import "DNSKitTests.h"
@import DNSKit;

@interface DNSMessageTests : XCTestCase

@end

@implementation DNSMessageTests

- (void) setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) testParseDNSMessage {
    uint8_t messageLiteral[] = { 0xa5, 0x9f, 0x81, 0x80, 0x00, 0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x03, 0x64, 0x6e, 0x73, 0x06, 0x67, 0x6f, 0x6f, 0x67, 0x6c, 0x65, 0x00, 0x00, 0x01, 0x00, 0x01, 0xc0, 0x0c, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x2a, 0x00, 0x04, 0x08, 0x08, 0x08, 0x08, 0xc0, 0x0c, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x2a, 0x00, 0x04, 0x08, 0x08, 0x04, 0x04 };
    NSData * messageData = [NSData dataWithBytes:messageLiteral length:60];
    NSError * messageError;
    DNSMessage * message = [DNSMessage messageFromData:messageData error:&messageError];
    XCTAssertNil(messageError);
    XCTAssertNotNil(message);
    XCTAssertNotNil(message.questions);
    XCTAssertNotNil(message.answers);
    XCTAssertEqual(message.questions.count, 1);
    XCTAssertEqual(message.answers.count, 2);
    XCTAssertStringEqual(message.questions[0].name, @"dns.google.");
    XCTAssertStringEqual(message.answers[0].name, @"dns.google.");
    XCTAssertStringEqual(message.answers[1].name, @"dns.google.");
    XCTAssertStringEqual([[NSString alloc] initWithData:message.answers[0].data encoding:NSASCIIStringEncoding], @"8.8.8.8");
    XCTAssertStringEqual([[NSString alloc] initWithData:message.answers[1].data encoding:NSASCIIStringEncoding], @"8.8.4.4");
}

@end
