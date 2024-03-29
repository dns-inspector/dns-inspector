#import "DNSClientDNS.h"
#import "NSData+HexString.h"
#import "IPAddressParser.h"
@import Network;

@interface DNSClientDNS ()

@property (strong, nonatomic) NSString * host;
@property (nonatomic) NSUInteger port;

@end

@implementation DNSClientDNS

+ (DNSClient *) serverWithAddress:(NSString *)address error:(NSError **)error {
    DNSClientDNS * dns = [DNSClientDNS new];

    IPAddressParser * addressParser = [IPAddressParser new];
    NSError * addressError = [addressParser parseString:address];
    if (addressError != nil) {
        *error = addressError;
        return nil;
    }
    dns.host = addressParser.ipAddress;
    dns.port = addressParser.port > 0 ? addressParser.port : 53;

    return dns;
}

- (void) sendMessage:(DNSMessage *)message gotReply:(void (^)(DNSMessage *, NSError *))completed {
    PDebug(@"Sending DNS query to %@:%i using %@", self.host, (int)self.port, self.useTCP.boolValue ? @"TCP" : @"UDP");

    NSError * messageError;
    NSData * dnsMessage = [message messageDataError:&messageError];
    if (messageError != nil) {
        completed(nil, messageError);
        return;
    }

    NSMutableData * messageData;

    if (self.useTCP.boolValue) {
        // TCP message is length+data
        messageData = [NSMutableData dataWithCapacity:dnsMessage.length+2];
        uint16_t length = htons((uint16_t)dnsMessage.length);
        [messageData appendBytes:&length length:2];
        [messageData appendData:dnsMessage];
    } else {
        messageData = [NSMutableData dataWithData:dnsMessage];
    }
    PDebug(@"Request: %@", messageData.hexString);

    // For some reason network framework expects the port to be a string...???
    const char * portStr = [[NSString alloc] initWithFormat:@"%i", (int)self.port].UTF8String;
    nw_endpoint_t endpoint = nw_endpoint_create_host(self.host.UTF8String, portStr);

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block gotReply = @NO;

    dispatch_queue_t nw_dispatch_queue = dispatch_queue_create("io.ecn.DNSKit.DNSClientDNS", NULL);

    nw_parameters_t parameters = self.useTCP.boolValue ? nw_parameters_create_secure_tcp(NW_PARAMETERS_DISABLE_PROTOCOL, NW_PARAMETERS_DEFAULT_CONFIGURATION) : nw_parameters_create_secure_udp(NW_PARAMETERS_DISABLE_PROTOCOL, NW_PARAMETERS_DEFAULT_CONFIGURATION);

    nw_connection_t connection = nw_connection_create(endpoint, parameters);
    nw_connection_set_queue(connection, nw_dispatch_queue);
    nw_connection_set_state_changed_handler(connection, ^(nw_connection_state_t state, nw_error_t error) {
        switch (state) {
            case nw_connection_state_invalid: {
                PDebug(@"Event: nw_connection_state_invalid");
                break;
            }
            case nw_connection_state_waiting: {
                PDebug(@"Event: nw_connection_state_waiting");
                PError(@"nw_connection failed: %@", error.description);
                int errorCode = -1;
                NSString * errorDescription = @"timed out";
                if (error != nil) {
                    errorCode = nw_error_get_error_code(error);
                    errorDescription = error.debugDescription;
                } else {
                    PError(@"nw_connection_state_waiting with no error");
                }
                completed(nil, MAKE_ERROR(errorCode, errorDescription));
                nw_connection_cancel(connection);
                break;
            }
            case nw_connection_state_preparing: {
                PDebug(@"Event: nw_connection_state_preparing");
                break;
            }
            case nw_connection_state_ready: {
                PDebug(@"Event: nw_connection_state_ready");

                NSMutableData * replyData = [NSMutableData new];
                dispatch_data_t data = dispatch_data_create(messageData.bytes, messageData.length, dispatch_get_main_queue(), DISPATCH_DATA_DESTRUCTOR_DEFAULT);

                int minLength = 2;
                int maxLength = self.useTCP.boolValue ? 2 : 512;

                nw_connection_receive(connection, minLength, maxLength, ^(dispatch_data_t firstData, nw_content_context_t firstContext, bool lengthIsComplete, nw_error_t lengthError) {
                    if (error != nil) {
                        completed(nil, MAKE_ERROR(1, error.description));
                        nw_connection_cancel(connection);
                        return;
                    }
                    if (firstData == nil) {
                        PDebug(@"nw_connection_receive with no content");
                        nw_connection_cancel(connection);
                        return;
                    }

                    PDebug(@"Read %i", (int)((NSData *)firstData).length);

                    if (!self.useTCP.boolValue) {
                        gotReply = @true;

                        NSError * replyError;
                        DNSMessage * reply = [DNSMessage messageFromData:(NSData*)firstData error:&replyError];
                        if (replyError != nil) {
                            completed(nil, replyError);
                            nw_connection_cancel(connection);
                            return;
                        }

                        completed(reply, nil);
                        nw_connection_cancel(connection);
                        dispatch_semaphore_signal(sync);
                        return;
                    }

                    uint16_t * nlen = (uint16_t *)((NSData *)firstData).bytes;
                    uint16_t length = ntohs(*nlen);
                    if (length == 0) {
                        PError(@"Invalid message length %i", (int)length);
                        completed(nil, MAKE_ERROR(1, @"Bad response"));
                        nw_connection_cancel(connection);
                        return;
                    }

                    nw_connection_receive(connection, length, length, ^(dispatch_data_t messageContent, nw_content_context_t messageContext, bool messageIsComplete, nw_error_t messageError) {
                        if (messageContent == nil) {
                            PDebug(@"nw_connection_receive with no content");
                            nw_connection_cancel(connection);
                            return;
                        }
                        gotReply = @true;

                        uint16_t actualLength = (uint16_t)((NSData*)messageContent).length;
                        if (actualLength < length) {
                            PError(@"Unexpected EOF reading reply. Wanted %iB got %iB", (int)length, (int)actualLength);
                            completed(nil, MAKE_ERROR(1, @"Bad response"));
                            nw_connection_cancel(connection);
                            return;
                        } else if (actualLength > length) {
                            PError(@"Actual data length exceeded stated length. Wanted %iB got %iB", (int)length, (int)actualLength);
                            completed(nil, MAKE_ERROR(1, @"Bad response"));
                            nw_connection_cancel(connection);
                            return;
                        }

                        PDebug(@"Read %i", (int)length);

                        [replyData appendData:(NSData*)messageContent];
                        NSError * replyError;
                        DNSMessage * reply = [DNSMessage messageFromData:replyData error:&replyError];
                        if (replyError != nil) {
                            completed(nil, replyError);
                            nw_connection_cancel(connection);
                            return;
                        }

                        completed(reply, nil);
                        nw_connection_cancel(connection);
                        dispatch_semaphore_signal(sync);
                        return;
                    });
                });

                nw_connection_send(connection, data, NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT, true, ^(nw_error_t  _Nullable error) {
                    if (error != nil) {
                        completed(nil, MAKE_ERROR(1, error.description));
                        return;
                    }
                    PDebug(@"Wrote %i", (int)messageData.length);
                });

                break;
            }
            case nw_connection_state_failed: {
                PDebug(@"Event: nw_connection_state_failed");
                PError(@"nw_connection failed: %@", error.description);
                completed(nil, MAKE_ERROR(nw_error_get_error_code(error), error.description));
                break;
            }
            case nw_connection_state_cancelled: {
                if (!gotReply.boolValue) {
                    PDebug(@"Event: nw_connection_state_cancelled");
                    NSString * errorDescription = @"timed out";
                    completed(nil, MAKE_ERROR(-1, errorDescription));
                }
                break;
            }
            default: {
                PError(@"Unknown nw_connection_state: %u", state);
                break;
            }
        }
    });
    nw_connection_start(connection);

    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)));
    if (!gotReply.boolValue) {
        // Timeout
        PDebug(@"No response from server within 5 seconds");
        nw_connection_cancel(connection);
    }
}

@end
