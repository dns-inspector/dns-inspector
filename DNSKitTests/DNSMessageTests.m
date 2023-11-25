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

- (void) testParseDNSAMessage {
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
    XCTAssertEqual(message.answers[0].ttlSeconds, 42);
    XCTAssertEqual(message.answers[1].ttlSeconds, 42);
    XCTAssertEqual(message.answers[0].recordType, DNSRecordTypeA);
    XCTAssertEqual(message.answers[1].recordType, DNSRecordTypeA);
    DNSARecordData * data1 = (DNSARecordData *)message.answers[0].data;
    DNSARecordData * data2 = (DNSARecordData *)message.answers[1].data;
    XCTAssertNotNil(data1);
    XCTAssertNotNil(data2);
    XCTAssertStringEqual(data1.ipAddress, @"8.8.8.8");
    XCTAssertStringEqual(data2.ipAddress, @"8.8.4.4");
}

- (void) testParseDNSAAAAMessage {
    uint8_t messageLiteral[] = { 0x33, 0xb1, 0x81, 0x80, 0x00, 0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x03, 0x64, 0x6e, 0x73, 0x06, 0x67, 0x6f, 0x6f, 0x67, 0x6c, 0x65, 0x00, 0x00, 0x1c, 0x00, 0x01, 0xc0, 0x0c, 0x00, 0x1c, 0x00, 0x01, 0x00, 0x00, 0x02, 0x5b, 0x00, 0x10, 0x20, 0x01, 0x48, 0x60, 0x48, 0x60, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x88, 0x88, 0xc0, 0x0c, 0x00, 0x1c, 0x00, 0x01, 0x00, 0x00, 0x02, 0x5b, 0x00, 0x10, 0x20, 0x01, 0x48, 0x60, 0x48, 0x60, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x88, 0x44 };
    NSData * messageData = [NSData dataWithBytes:messageLiteral length:84];
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
    XCTAssertEqual(message.answers[0].ttlSeconds, 603);
    XCTAssertEqual(message.answers[1].ttlSeconds, 603);
    XCTAssertEqual(message.answers[0].recordType, DNSRecordTypeAAAA);
    XCTAssertEqual(message.answers[1].recordType, DNSRecordTypeAAAA);
    DNSAAAARecordData * data1 = (DNSAAAARecordData *)message.answers[0].data;
    DNSAAAARecordData * data2 = (DNSAAAARecordData *)message.answers[1].data;
    XCTAssertNotNil(data1);
    XCTAssertNotNil(data2);
    XCTAssertStringEqual(data1.ipAddress, @"2001:4860:4860::8888");
    XCTAssertStringEqual(data2.ipAddress, @"2001:4860:4860::8844");
}

- (void) testParseDNSCNAMEMessage {
    uint8_t messageLiteral[] = { 0xdb, 0x15, 0x81, 0x80, 0x00, 0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x05, 0x63, 0x6e, 0x61, 0x6d, 0x65, 0x07, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x03, 0x63, 0x6f, 0x6d, 0x00, 0x00, 0x01, 0x00, 0x01, 0xc0, 0x0c, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x01, 0x2c, 0x00, 0x07, 0x04, 0x68, 0x6f, 0x73, 0x74, 0xc0, 0x12, 0xc0, 0x2f, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x01, 0x2c, 0x00, 0x04, 0x7f, 0x00, 0x00, 0x01 };
    NSData * messageData = [NSData dataWithBytes:messageLiteral length:70];
    NSError * messageError;
    DNSMessage * message = [DNSMessage messageFromData:messageData error:&messageError];
    XCTAssertNil(messageError);
    XCTAssertNotNil(message);
    XCTAssertNotNil(message.questions);
    XCTAssertNotNil(message.answers);
    XCTAssertEqual(message.questions.count, 1);
    XCTAssertEqual(message.answers.count, 2);
    XCTAssertStringEqual(message.questions[0].name, @"cname.example.com.");
    XCTAssertStringEqual(message.answers[0].name, @"cname.example.com.");
    XCTAssertStringEqual(message.answers[1].name, @"host.example.com.");
    XCTAssertEqual(message.answers[0].ttlSeconds, 300);
    XCTAssertEqual(message.answers[1].ttlSeconds, 300);
    XCTAssertEqual(message.answers[0].recordType, DNSRecordTypeCNAME);
    XCTAssertEqual(message.answers[1].recordType, DNSRecordTypeA);
    DNSCNAMERecordData * data1 = (DNSCNAMERecordData *)message.answers[0].data;
    DNSARecordData * data2 = (DNSARecordData *)message.answers[1].data;
    XCTAssertNotNil(data1);
    XCTAssertNotNil(data2);
    XCTAssertStringEqual(data1.name, @"host.example.com.");
    XCTAssertStringEqual(data2.ipAddress, @"127.0.0.1");
}

- (void) testParseDNSMXMessage {
    uint8_t messageLiteral[] = { 0xe3, 0x85, 0x81, 0x80, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x07, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x03, 0x63, 0x6f, 0x6d, 0x00, 0x00, 0x0f, 0x00, 0x01, 0xc0, 0x0c, 0x00, 0x0f, 0x00, 0x01, 0x00, 0x00, 0x01, 0x2c, 0x00, 0x09, 0x00, 0x0a, 0x04, 0x6d, 0x61, 0x69, 0x6c, 0xc0, 0x0c };
    NSData * messageData = [NSData dataWithBytes:messageLiteral length:50];
    NSError * messageError;
    DNSMessage * message = [DNSMessage messageFromData:messageData error:&messageError];
    XCTAssertNil(messageError);
    XCTAssertNotNil(message);
    XCTAssertNotNil(message.questions);
    XCTAssertNotNil(message.answers);
    XCTAssertEqual(message.questions.count, 1);
    XCTAssertEqual(message.answers.count, 1);
    XCTAssertStringEqual(message.questions[0].name, @"example.com.");
    XCTAssertStringEqual(message.answers[0].name, @"example.com.");
    XCTAssertEqual(message.answers[0].ttlSeconds, 300);
    XCTAssertEqual(message.answers[0].recordType, DNSRecordTypeMX);
    DNSMXRecordData * data = (DNSMXRecordData *)message.answers[0].data;
    XCTAssertNotNil(data);
    XCTAssertStringEqual(data.name, @"mail.example.com.");
    XCTAssertEqual(data.priority.unsignedIntValue, 10);
}

- (void) testParseDNSSRVMessage {
    uint8_t messageLiteral[] = { 0xb3, 0xbd, 0x81, 0x80, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x08, 0x5f, 0x73, 0x65, 0x72, 0x76, 0x69, 0x63, 0x65, 0x04, 0x5f, 0x74, 0x63, 0x70, 0x07, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x03, 0x63, 0x6f, 0x6d, 0x00, 0x00, 0x21, 0x00, 0x01, 0xc0, 0x0c, 0x00, 0x21, 0x00, 0x01, 0x00, 0x00, 0x01, 0x2c, 0x00, 0x18, 0x00, 0x0a, 0x00, 0x00, 0x00, 0x7b, 0x04, 0x68, 0x6f, 0x73, 0x74, 0x07, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x03, 0x63, 0x6f, 0x6d, 0x00 };
    NSData * messageData = [NSData dataWithBytes:messageLiteral length:79];
    NSError * messageError;
    DNSMessage * message = [DNSMessage messageFromData:messageData error:&messageError];
    XCTAssertNil(messageError);
    XCTAssertNotNil(message);
    XCTAssertNotNil(message.questions);
    XCTAssertNotNil(message.answers);
    XCTAssertEqual(message.questions.count, 1);
    XCTAssertEqual(message.answers.count, 1);
    XCTAssertStringEqual(message.questions[0].name, @"_service._tcp.example.com.");
    XCTAssertStringEqual(message.answers[0].name, @"_service._tcp.example.com.");
    XCTAssertEqual(message.answers[0].ttlSeconds, 300);
    XCTAssertEqual(message.answers[0].recordType, DNSRecordTypeSRV);
    DNSSRVRecordData * data = (DNSSRVRecordData *)message.answers[0].data;
    XCTAssertNotNil(data);
    XCTAssertStringEqual(data.name, @"host.example.com.");
    XCTAssertEqual(data.priority.unsignedIntValue, 10);
    XCTAssertEqual(data.weight.unsignedIntValue, 0);
    XCTAssertEqual(data.port.unsignedIntValue, 123);
}

- (void) testParseDNSPTRMessage {
    uint8_t messageLiteral[] = { 0x46, 0xe7, 0x81, 0x80, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x31, 0x01, 0x30, 0x01, 0x30, 0x03, 0x31, 0x32, 0x37, 0x07, 0x69, 0x6e, 0x2d, 0x61, 0x64, 0x64, 0x72, 0x04, 0x61, 0x72, 0x70, 0x61, 0x00, 0x00, 0x0c, 0x00, 0x01, 0xc0, 0x0c, 0x00, 0x0c, 0x00, 0x01, 0x00, 0x01, 0x51, 0x80, 0x00, 0x0b, 0x09, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x68, 0x6f, 0x73, 0x74, 0x00 };
    NSData * messageData = [NSData dataWithBytes:messageLiteral length:63];
    NSError * messageError;
    DNSMessage * message = [DNSMessage messageFromData:messageData error:&messageError];
    XCTAssertNil(messageError);
    XCTAssertNotNil(message);
    XCTAssertNotNil(message.questions);
    XCTAssertNotNil(message.answers);
    XCTAssertEqual(message.questions.count, 1);
    XCTAssertEqual(message.answers.count, 1);
    XCTAssertStringEqual(message.questions[0].name, @"1.0.0.127.in-addr.arpa.");
    XCTAssertStringEqual(message.answers[0].name, @"1.0.0.127.in-addr.arpa.");
    XCTAssertEqual(message.answers[0].ttlSeconds, 86400);
    XCTAssertEqual(message.answers[0].recordType, DNSRecordTypePTR);
    DNSPTRRecordData * data = (DNSPTRRecordData *)message.answers[0].data;
    XCTAssertNotNil(data);
    XCTAssertStringEqual(data.name, @"localhost.");
}

- (void) testParseDNSTXTMessage {
    uint8_t messageLiteral[] = { 0x0a, 0xbb, 0x81, 0x80, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x07, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x03, 0x63, 0x6f, 0x6d, 0x00, 0x00, 0x10, 0x00, 0x01, 0xc0, 0x0c, 0x00, 0x10, 0x00, 0x01, 0x00, 0x00, 0x00, 0x9d, 0x02, 0x53, 0xff, 0x54, 0x68, 0x69, 0x73, 0x20, 0x69, 0x73, 0x20, 0x6f, 0x75, 0x72, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x20, 0x6e, 0x6f, 0x77, 0x2e, 0x2e, 0x2e, 0x20, 0x74, 0x68, 0x65, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x20, 0x6f, 0x66, 0x20, 0x74, 0x68, 0x65, 0x20, 0x65, 0x6c, 0x65, 0x63, 0x74, 0x72, 0x6f, 0x6e, 0x20, 0x61, 0x6e, 0x64, 0x20, 0x74, 0x68, 0x65, 0x20, 0x73, 0x77, 0x69, 0x74, 0x63, 0x68, 0x2c, 0x20, 0x74, 0x68, 0x65, 0x20, 0x62, 0x65, 0x61, 0x75, 0x74, 0x79, 0x20, 0x6f, 0x66, 0x20, 0x74, 0x68, 0x65, 0x20, 0x62, 0x61, 0x75, 0x64, 0x2e, 0x20, 0x20, 0x57, 0x65, 0x20, 0x6d, 0x61, 0x6b, 0x65, 0x20, 0x75, 0x73, 0x65, 0x20, 0x6f, 0x66, 0x20, 0x61, 0x20, 0x73, 0x65, 0x72, 0x76, 0x69, 0x63, 0x65, 0x20, 0x61, 0x6c, 0x72, 0x65, 0x61, 0x64, 0x79, 0x20, 0x65, 0x78, 0x69, 0x73, 0x74, 0x69, 0x6e, 0x67, 0x20, 0x77, 0x69, 0x74, 0x68, 0x6f, 0x75, 0x74, 0x20, 0x70, 0x61, 0x79, 0x69, 0x6e, 0x67, 0x20, 0x66, 0x6f, 0x72, 0x20, 0x77, 0x68, 0x61, 0x74, 0x20, 0x63, 0x6f, 0x75, 0x6c, 0x64, 0x20, 0x62, 0x65, 0x20, 0x64, 0x69, 0x72, 0x74, 0x2d, 0x63, 0x68, 0x65, 0x61, 0x70, 0x20, 0x69, 0x66, 0x20, 0x69, 0x74, 0x20, 0x77, 0x61, 0x73, 0x6e, 0x74, 0x20, 0x72, 0x75, 0x6e, 0x20, 0x62, 0x79, 0x20, 0x70, 0x72, 0x6f, 0x66, 0x69, 0x74, 0x65, 0x65, 0x72, 0x69, 0x6e, 0x67, 0x20, 0x67, 0x6c, 0x75, 0x74, 0x74, 0x6f, 0x6e, 0x73, 0x2c, 0x20, 0x61, 0x6e, 0x64, 0x20, 0x79, 0x6f, 0x75, 0x20, 0x63, 0x61, 0x6c, 0x6c, 0x20, 0x75, 0x73, 0x20, 0x63, 0x72, 0x69, 0x6d, 0x69, 0x6e, 0x61, 0x6c, 0x73, 0x2e, 0x20, 0x20, 0x57, 0x65, 0x20, 0x65, 0x78, 0x70, 0x6c, 0xff, 0x6f, 0x72, 0x65, 0x2e, 0x2e, 0x2e, 0x20, 0x61, 0x6e, 0x64, 0x20, 0x79, 0x6f, 0x75, 0x20, 0x63, 0x61, 0x6c, 0x6c, 0x20, 0x75, 0x73, 0x20, 0x63, 0x72, 0x69, 0x6d, 0x69, 0x6e, 0x61, 0x6c, 0x73, 0x2e, 0x20, 0x20, 0x57, 0x65, 0x20, 0x73, 0x65, 0x65, 0x6b, 0x20, 0x61, 0x66, 0x74, 0x65, 0x72, 0x20, 0x6b, 0x6e, 0x6f, 0x77, 0x6c, 0x65, 0x64, 0x67, 0x65, 0x2e, 0x2e, 0x2e, 0x20, 0x61, 0x6e, 0x64, 0x20, 0x79, 0x6f, 0x75, 0x20, 0x63, 0x61, 0x6c, 0x6c, 0x20, 0x75, 0x73, 0x20, 0x63, 0x72, 0x69, 0x6d, 0x69, 0x6e, 0x61, 0x6c, 0x73, 0x2e, 0x20, 0x20, 0x57, 0x65, 0x20, 0x65, 0x78, 0x69, 0x73, 0x74, 0x20, 0x77, 0x69, 0x74, 0x68, 0x6f, 0x75, 0x74, 0x20, 0x73, 0x6b, 0x69, 0x6e, 0x20, 0x63, 0x6f, 0x6c, 0x6f, 0x72, 0x2c, 0x20, 0x77, 0x69, 0x74, 0x68, 0x6f, 0x75, 0x74, 0x20, 0x6e, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x61, 0x6c, 0x69, 0x74, 0x79, 0x2c, 0x20, 0x77, 0x69, 0x74, 0x68, 0x6f, 0x75, 0x74, 0x20, 0x72, 0x65, 0x6c, 0x69, 0x67, 0x69, 0x6f, 0x75, 0x73, 0x20, 0x62, 0x69, 0x61, 0x73, 0x2e, 0x2e, 0x2e, 0x20, 0x61, 0x6e, 0x64, 0x20, 0x79, 0x6f, 0x75, 0x20, 0x63, 0x61, 0x6c, 0x6c, 0x20, 0x75, 0x73, 0x20, 0x63, 0x72, 0x69, 0x6d, 0x69, 0x6e, 0x61, 0x6c, 0x73, 0x2e, 0x20, 0x59, 0x6f, 0x75, 0x20, 0x62, 0x75, 0x69, 0x6c, 0x64, 0x20, 0x61, 0x74, 0x6f, 0x6d, 0x69, 0x63, 0x20, 0x62, 0x6f, 0x6d, 0x62, 0x73, 0x2c, 0x20, 0x79, 0x6f, 0x75, 0x20, 0x77, 0x61, 0x67, 0x65, 0x20, 0x77, 0x61, 0x72, 0x73, 0x2c, 0x20, 0x79, 0x6f, 0x75, 0x20, 0x6d, 0x75, 0x72, 0x64, 0x65, 0x72, 0x2c, 0x20, 0x63, 0x68, 0x65, 0x61, 0x74, 0x2c, 0x20, 0x61, 0x6e, 0x64, 0x20, 0x52, 0x6c, 0x69, 0x65, 0x20, 0x74, 0x6f, 0x20, 0x75, 0x73, 0x20, 0x61, 0x6e, 0x64, 0x20, 0x74, 0x72, 0x79, 0x20, 0x74, 0x6f, 0x20, 0x6d, 0x61, 0x6b, 0x65, 0x20, 0x75, 0x73, 0x20, 0x62, 0x65, 0x6c, 0x69, 0x65, 0x76, 0x65, 0x20, 0x69, 0x74, 0x73, 0x20, 0x66, 0x6f, 0x72, 0x20, 0x6f, 0x75, 0x72, 0x20, 0x6f, 0x77, 0x6e, 0x20, 0x67, 0x6f, 0x6f, 0x64, 0x2c, 0x20, 0x79, 0x65, 0x74, 0x20, 0x77, 0x65, 0x72, 0x65, 0x20, 0x74, 0x68, 0x65, 0x20, 0x63, 0x72, 0x69, 0x6d, 0x69, 0x6e, 0x61, 0x6c, 0x73, 0x2e };
    NSData * messageData = [NSData dataWithBytes:messageLiteral length:636];
    NSError * messageError;
    DNSMessage * message = [DNSMessage messageFromData:messageData error:&messageError];
    XCTAssertNil(messageError);
    XCTAssertNotNil(message);
    XCTAssertNotNil(message.questions);
    XCTAssertNotNil(message.answers);
    XCTAssertEqual(message.questions.count, 1);
    XCTAssertEqual(message.answers.count, 1);
    XCTAssertStringEqual(message.questions[0].name, @"example.com.");
    XCTAssertStringEqual(message.answers[0].name, @"example.com.");
    XCTAssertEqual(message.answers[0].ttlSeconds, 157);
    XCTAssertEqual(message.answers[0].recordType, DNSRecordTypeTXT);
    DNSTXTRecordData * data = (DNSTXTRecordData *)message.answers[0].data;
    XCTAssertNotNil(data);
    XCTAssertStringEqual(data.text, @"This is our world now... the world of the electron and the switch, the beauty of the baud.  We make use of a service already existing without paying for what could be dirt-cheap if it wasnt run by profiteering gluttons, and you call us criminals.  We expl" "ore... and you call us criminals.  We seek after knowledge... and you call us criminals.  We exist without skin color, without nationality, without religious bias... and you call us criminals. You build atomic bombs, you wage wars, you murder, cheat, and " "lie to us and try to make us believe its for our own good, yet were the criminals.");
}

- (void) testParseDNSNXDOMAINMessage {
    uint8_t messageLiteral[] = { 0xbd, 0x25, 0x81, 0x83, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x19, 0x74, 0x68, 0x69, 0x73, 0x2d, 0x64, 0x6f, 0x6d, 0x61, 0x69, 0x6e, 0x2d, 0x64, 0x6f, 0x65, 0x73, 0x2d, 0x6e, 0x6f, 0x74, 0x2d, 0x65, 0x78, 0x69, 0x74, 0x02, 0x63, 0x61, 0x00, 0x00, 0x01, 0x00, 0x01, 0xc0, 0x26, 0x00, 0x06, 0x00, 0x01, 0x00, 0x00, 0x0e, 0x10, 0x00, 0x37, 0x0a, 0x70, 0x72, 0x64, 0x2d, 0x63, 0x7a, 0x70, 0x2d, 0x30, 0x35, 0x04, 0x63, 0x6f, 0x72, 0x70, 0x04, 0x63, 0x69, 0x72, 0x61, 0xc0, 0x26, 0x09, 0x61, 0x64, 0x6d, 0x69, 0x6e, 0x2d, 0x64, 0x6e, 0x73, 0xc0, 0x4a, 0x89, 0xbf, 0xfb, 0xb0, 0x00, 0x00, 0x08, 0x34, 0x00, 0x00, 0x03, 0x84, 0x00, 0x34, 0xbc, 0x00, 0x00, 0x00, 0x0e, 0x10 };
    NSData * messageData = [NSData dataWithBytes:messageLiteral length:113];
    NSError * messageError;
    DNSMessage * message = [DNSMessage messageFromData:messageData error:&messageError];
    XCTAssertNil(messageError);
    XCTAssertNotNil(message);
    XCTAssertNotNil(message.questions);
    XCTAssertEqual(message.responseCode, DNSResponseCodeNXDOMAIN);
    XCTAssertNil(message.answers);
    XCTAssertEqual(message.questions.count, 1);
    XCTAssertStringEqual(message.questions[0].name, @"this-domain-does-not-exit.ca.");
}

@end
