#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "DNSKitTests.h"
@import DNSKit;
#import "../DNSKit/DNSClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSClientTests : NSObject

+ (DNSClientTests *) fixtureWithClientType:(DNSClientType)clientType client:(DNSClient *)client;
- (void) testQueryA;
- (void) testQueryAAAA;
- (void) testQueryNXDOMAIN;
- (void) testQueryTimeout;

@end

NS_ASSUME_NONNULL_END
