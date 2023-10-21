#import "DNSServerTLS.h"
@import Network;

@interface DNSServerTLS ()

@property (strong, nonatomic) NSString * host;
@property (nonatomic) NSUInteger port;

@end

@implementation DNSServerTLS

+ (DNSServer *) serverWithAddress:(NSString *)address error:(NSError **)error {
    DNSServerTLS * dns = [DNSServerTLS new];
    return dns;
}

- (void) sendMessage:(DNSMessage *)message gotReply:(void (^)(DNSMessage *, NSError *))completed {
    // For some reason network framework expects the port to be a string...???
    const char * portStr = [[NSString alloc] initWithFormat:@"%i", (int)self.port].UTF8String;
    nw_endpoint_t endpoint = nw_endpoint_create_host(self.host.UTF8String, portStr);

    dispatch_queue_t nw_dispatch_queue = dispatch_queue_create("io.ecn.DNSKit.DNSServerTLS", NULL);

    // TCP configuration
    nw_parameters_configure_protocol_block_t configure_tcp = ^(nw_protocol_options_t tcp_options) {};
    nw_parameters_configure_protocol_block_t configure_tls = ^(nw_protocol_options_t tls_options) {};

    nw_parameters_t nwparameters = nw_parameters_create_secure_tcp(configure_tls, configure_tcp);

    nw_connection_t connection = nw_connection_create(endpoint, nwparameters);
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
                //
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
