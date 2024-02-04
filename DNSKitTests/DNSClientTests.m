#import "DNSClientTests.h"

@interface DNSClientTests ()

@property (nonatomic) DNSClientType clientType;
@property (strong, nonatomic, nonnull) DNSClient * client;

@end

@implementation DNSClientTests

#define TEST_TIMEOUT 10 // Seconds

+ (DNSClientTests *) fixtureWithClientType:(DNSClientType)clientType client:(DNSClient *)client {
    DNSClientTests * fixture = [DNSClientTests new];
    fixture.clientType = clientType;
    fixture.client = client;
    return fixture;
}

- (NSString *) mockServerAddressForQuery {
    // These addresses are NOT used in the actual test
    switch (self.clientType) {
        case DNSClientTypeDNS:
            return @"0.0.0.0";
        case DNSClientTypeTLS:
            return @"0.0.0.0";
        case DNSClientTypeHTTPS:
            return @"https://a";
    }

    return @"";
}

- (void) testQueryA {
    NSError * queryError;
    DNSQuery * query = [DNSQuery queryWithClientType:self.clientType serverAddress:[self mockServerAddressForQuery] recordType:DNSRecordTypeA name:@"dns.google" parameters:nil error:&queryError];
    if (queryError != nil) {
        XCTAssertNil(queryError);
        return;
    }

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;

    [self.client sendMessage:[query dnsMessage] gotReply:^(DNSMessage * message, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(message);
        XCTAssertTrue(message.answers.count > 0);
        XCTAssertEqual(message.responseCode, DNSResponseCodeSuccess);

        for (DNSAnswer * answer in message.answers) {
            DNSARecordData * data = (DNSARecordData *)answer.data;
            XCTAssertTrue([[data ipAddress] isEqualToString:@"8.8.8.8"] || [[data ipAddress] isEqualToString:@"8.8.4.4"]);
        }

        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testQueryNS {
    NSError * queryError;
    DNSQuery * query = [DNSQuery queryWithClientType:self.clientType serverAddress:[self mockServerAddressForQuery] recordType:DNSRecordTypeNS name:@"dns.google" parameters:nil error:&queryError];
    if (queryError != nil) {
        XCTAssertNil(queryError);
        return;
    }

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;

    [self.client sendMessage:[query dnsMessage] gotReply:^(DNSMessage * message, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(message);
        XCTAssertTrue(message.answers.count > 0);
        XCTAssertEqual(message.responseCode, DNSResponseCodeSuccess);

        for (DNSAnswer * answer in message.answers) {
            DNSNSRecordData * data = (DNSNSRecordData *)answer.data;
            XCTAssertTrue([[data name] isEqualToString:@"a.iana-servers.net."] || [[data name] isEqualToString:@"b.iana-servers.net."]);
        }

        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testQueryAAAA {
    NSError * queryError;
    DNSQuery * query = [DNSQuery queryWithClientType:self.clientType serverAddress:[self mockServerAddressForQuery] recordType:DNSRecordTypeAAAA name:@"dns.google" parameters:nil error:&queryError];
    if (queryError != nil) {
        XCTAssertNil(queryError);
        return;
    }

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;

    [self.client sendMessage:[query dnsMessage] gotReply:^(DNSMessage * message, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(message);
        XCTAssertTrue(message.answers.count > 0);
        XCTAssertEqual(message.responseCode, DNSResponseCodeSuccess);

        for (DNSAnswer * answer in message.answers) {
            DNSARecordData * data = (DNSARecordData *)answer.data;
            XCTAssertTrue([[data ipAddress] isEqualToString:@"2001:4860:4860::8888"] || [[data ipAddress] isEqualToString:@"2001:4860:4860::8844"]);
        }

        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testQueryNXDOMAIN {
    NSError * queryError;
    DNSQuery * query = [DNSQuery queryWithClientType:self.clientType serverAddress:[self mockServerAddressForQuery] recordType:DNSRecordTypeA name:@"if-you-register-this-domain-im-going-to-be-very-angry.com" parameters:nil error:&queryError];
    if (queryError != nil) {
        XCTAssertNil(queryError);
        return;
    }

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;

    [self.client sendMessage:[query dnsMessage] gotReply:^(DNSMessage * message, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(message);
        XCTAssertTrue(message.answers.count == 0);
        XCTAssertEqual(message.responseCode, DNSResponseCodeNXDOMAIN);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testQueryTimeout {
    NSError * queryError;
    DNSQueryParameters * parameters = [DNSQueryParameters new];
    parameters.dnsPrefersTcp = true;
    DNSQuery * query = [DNSQuery queryWithClientType:self.clientType serverAddress:[self mockServerAddressForQuery] recordType:DNSRecordTypeA name:@"just-a-test.com" parameters:parameters error:&queryError];
    if (queryError != nil) {
        XCTAssertNil(queryError);
        return;
    }

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;

    [self.client sendMessage:[query dnsMessage] gotReply:^(DNSMessage * message, NSError * error) {
        XCTAssertNotNil(error);
        XCTAssertTrue(message.answers.count == 0);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)((TEST_TIMEOUT * 3) * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testRandomData {
    NSError * queryError;
    DNSQuery * query = [DNSQuery queryWithClientType:self.clientType serverAddress:[self mockServerAddressForQuery] recordType:DNSRecordTypeA name:@"random.example.com" parameters:nil error:&queryError];
    if (queryError != nil) {
        XCTAssertNil(queryError);
        return;
    }

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;

    [self.client sendMessage:[query dnsMessage] gotReply:^(DNSMessage * message, NSError * error) {
        XCTAssertNotNil(error);
        XCTAssertNil(message);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testLengthOver {
    NSError * queryError;
    DNSQuery * query = [DNSQuery queryWithClientType:self.clientType serverAddress:[self mockServerAddressForQuery] recordType:DNSRecordTypeA name:@"length.over.example.com" parameters:nil error:&queryError];
    if (queryError != nil) {
        XCTAssertNil(queryError);
        return;
    }

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;

    [self.client sendMessage:[query dnsMessage] gotReply:^(DNSMessage * message, NSError * error) {
        XCTAssertNotNil(error);
        XCTAssertNil(message);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testLengthUnder {
    NSError * queryError;
    DNSQuery * query = [DNSQuery queryWithClientType:self.clientType serverAddress:[self mockServerAddressForQuery] recordType:DNSRecordTypeA name:@"length.under.example.com" parameters:nil error:&queryError];
    if (queryError != nil) {
        XCTAssertNil(queryError);
        return;
    }

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;

    [self.client sendMessage:[query dnsMessage] gotReply:^(DNSMessage * message, NSError * error) {
        XCTAssertNotNil(error);
        XCTAssertNil(message);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

@end
