#import "DNSClient53UDP.h"
#import "NSData+HexString.h"
@import Network;

@interface DNSClient53UDP ()

@property (strong, nonatomic) NSString * host;
@property (nonatomic) NSUInteger port;

@end

@implementation DNSClient53UDP

+ (DNSClient *) serverWithAddress:(NSString *)address error:(NSError **)error {
    DNSClient53UDP * dns = [DNSClient53UDP new];

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
    PDebug(@"%@", dnsMessage.hexString);

    // For some reason network framework expects the port to be a string...???
    const char * portStr = [[NSString alloc] initWithFormat:@"%i", (int)self.port].UTF8String;
    nw_endpoint_t endpoint = nw_endpoint_create_host(self.host.UTF8String, portStr);

    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block gotReply = @NO;

    dispatch_queue_t nw_dispatch_queue = dispatch_queue_create("io.ecn.DNSKit.DNSClient53UDP", NULL);

    nw_connection_t connection = nw_connection_create(endpoint, nw_parameters_create_secure_udp(NW_PARAMETERS_DISABLE_PROTOCOL, NW_PARAMETERS_DEFAULT_CONFIGURATION));
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

                nw_connection_receive(connection, 2, 512, ^(dispatch_data_t messageContent, nw_content_context_t messageContext, bool messageIsComplete, nw_error_t messageError) {
                    if (messageContent == nil) {
                        return;
                    }

                    gotReply = @true;
                    NSData * replyData = (NSData*)messageContent;
                    PDebug(@"Read %i", (int)replyData.length);
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
                    dispatch_semaphore_signal(sync);
                    return;
                });

                dispatch_data_t data = dispatch_data_create(dnsMessage.bytes, dnsMessage.length, dispatch_get_main_queue(), DISPATCH_DATA_DESTRUCTOR_DEFAULT);
                nw_connection_send(connection, data, NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT, true, ^(nw_error_t  _Nullable error) {
                    if (error != nil) {
                        completed(nil, MAKE_ERROR(1, error.description));
                        return;
                    }
                    PDebug(@"Wrote %i", (int)dnsMessage.length);
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
