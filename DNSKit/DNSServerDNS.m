#import "DNSServerDNS.h"
#import "NSData+HexString.h"
@import Network;

@interface DNSServerDNS ()

@property (strong, nonatomic) NSString * host;
@property (nonatomic) NSUInteger port;

@end

@implementation DNSServerDNS

+ (DNSServer *) serverWithAddress:(NSString *)address error:(NSError **)error {
    DNSServerDNS * dns = [DNSServerDNS new];

    NSRegularExpression * portPattern = [NSRegularExpression regularExpressionWithPattern:@":\\d{1,5}$" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> * matches = [portPattern matchesInString:address options:0 range:NSMakeRange(0, address.length)];
    if (matches.count == 1) {
        NSString * portStr = [address substringWithRange:NSMakeRange(matches[0].range.location+1, matches[0].range.length-1)];
        dns.port = (NSUInteger)[portStr integerValue];
        dns.host = [address substringToIndex:matches[0].range.location];
    } else {
        dns.port = 53;
        dns.host = address;
    }

    return dns;
}

- (void) sendMessage:(DNSMessage *)message gotReply:(void (^)(DNSMessage *, NSError *))completed {
    NSError * messageError;
    NSData * dnsMessage = [message messageDataError:&messageError];
    if (messageError != nil) {
        completed(nil, messageError);
        return;
    }
    NSMutableData * messageData = [NSMutableData dataWithCapacity:dnsMessage.length+2];
    uint16_t length = htons((uint16_t)dnsMessage.length);
    [messageData appendBytes:&length length:2];
    [messageData appendData:dnsMessage];
    PDebug(@"%@", messageData.hexString);

    // For some reason network framework expects the port to be a string...???
    const char * portStr = [[NSString alloc] initWithFormat:@"%i", (int)self.port].UTF8String;
    nw_endpoint_t endpoint = nw_endpoint_create_host(self.host.UTF8String, portStr);

    dispatch_queue_t nw_dispatch_queue = dispatch_queue_create("io.ecn.DNSKit.DNSServerDNS", NULL);

    nw_connection_t connection = nw_connection_create(endpoint, nw_parameters_create_secure_tcp(NW_PARAMETERS_DISABLE_PROTOCOL, NW_PARAMETERS_DEFAULT_CONFIGURATION));
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
                nw_connection_receive(connection, 2, 2, ^(dispatch_data_t lengthContent, nw_content_context_t lengthContext, bool lengthIsComplete, nw_error_t lengthError) {
                    if (error != nil) {
                        completed(nil, MAKE_ERROR(1, error.description));
                        nw_connection_cancel(connection);
                        return;
                    }
                    if (lengthContent == nil) {
                        PDebug(@"nw_connection_receive with no content");
                        nw_connection_cancel(connection);
                        return;
                    }

                    PDebug(@"Read 2");

                    uint16_t * nlen = (uint16_t *)((NSData *)lengthContent).bytes;
                    uint16_t length = ntohs(*nlen);
                    if (length == 0) {
                        PError(@"Invalid message length %i", (int)length);
                        completed(nil, MAKE_ERROR(1, @"Bad response"));
                        nw_connection_cancel(connection);
                        return;
                    }

                    nw_connection_receive(connection, length, length, ^(dispatch_data_t messageContent, nw_content_context_t messageContext, bool messageIsComplete, nw_error_t messageError) {
                        PDebug(@"Read %i", (int)length);

                        [replyData appendData:(NSData*)messageContent];
                        NSError * replyError;
                        DNSMessage * reply = [DNSMessage messageFromData:replyData error:&replyError];
                        if (replyError != nil) {
                            completed(nil, replyError);
                            nw_connection_cancel(connection);
                            return;
                        }

                        PDebug(@"Reply: %@", [replyData hexString]);
                        completed(reply, nil);
                        nw_connection_cancel(connection);
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
                PDebug(@"Event: nw_connection_state_cancelled");
                break;
            }
            default: {
                PError(@"Unknown nw_connection_state: %u", state);
                break;
            }
        }
    });
    nw_connection_start(connection);
}

@end
