#import <XCTest/XCTest.h>
#import "DNSKitTests.h"
@import DNSKit;

@interface DNSQueryTests : XCTestCase

@end

@implementation DNSQueryTests

#define TEST_TIMEOUT 10 // Seconds

- (void) setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) testValidateDNSClientConfigurationValidDNS {
    NSError * error = [DNSQuery validateDNSClientConfigurationWithClientType:DNSClientTypeDNS serverAddress:@"8.8.8.8" parameters:nil];
    XCTAssertNil(error);
}

- (void) testValidateDNSClientConfigurationValidDOT {
    NSError * error = [DNSQuery validateDNSClientConfigurationWithClientType:DNSClientTypeTLS serverAddress:@"8.8.8.8:853" parameters:nil];
    XCTAssertNil(error);
}

- (void) testValidateDNSClientConfigurationValidDOH {
    NSError * error = [DNSQuery validateDNSClientConfigurationWithClientType:DNSClientTypeHTTPS serverAddress:@"https://dns.google/dns-query" parameters:nil];
    XCTAssertNil(error);
}

- (void) testValidateDNSClientConfigurationInvalidDNS {
    NSError * error = [DNSQuery validateDNSClientConfigurationWithClientType:DNSClientTypeDNS serverAddress:@"8.8.8.8.8" parameters:nil];
    XCTAssertNotNil(error);
}

- (void) testValidateDNSClientConfigurationInvalidDOT {
    NSError * error = [DNSQuery validateDNSClientConfigurationWithClientType:DNSClientTypeTLS serverAddress:@"8.8.8.8:65536" parameters:nil];
    XCTAssertNotNil(error);
}

- (void) testValidateDNSClientConfigurationInvalidDOH {
    NSError * error = [DNSQuery validateDNSClientConfigurationWithClientType:DNSClientTypeHTTPS serverAddress:@"http://dns.google/dns-query" parameters:nil];
    XCTAssertNotNil(error);
}

- (void) testValidateDNSClientConfigurationInvalidClientType {
    NSError * error = [DNSQuery validateDNSClientConfigurationWithClientType:(DNSClientType)100 serverAddress:@"UwU WHATS THIS?" parameters:nil];
    XCTAssertNotNil(error);
}

@end
