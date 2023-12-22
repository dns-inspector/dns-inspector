#import "DNSClientHTTPS.h"
#import "NSData+HexString.h"
#import "NSData+Base64URL.h"
#import "NSHTTPURLResponse+HeaderValue.h"

@implementation DNSClientHTTPS

+ (DNSClient *) serverWithAddress:(NSString *)address error:(NSError **)error {
    DNSClientHTTPS * dns = [DNSClientHTTPS new];

    NSURL * url = [NSURL URLWithString:[address lowercaseString]];
    if (!url) {
        *error = MAKE_ERROR(1, @"Bad DNS over HTTPS server URL");
        return nil;
    }
    if (![url.scheme isEqualToString:@"https"]) {
        *error = MAKE_ERROR(1, @"Bad DNS over HTTPS server URL");
        return nil;
    }
    dns.address = address;

    return dns;
}

- (void) sendMessage:(DNSMessage *)message gotReply:(void (^)(DNSMessage *, NSError *))completed {
    NSError * questionError;
    NSData * questionData = [message messageDataError:&questionError];
    if (questionError != nil) {
        completed(nil, questionError);
        return;
    }

    PDebug(@"Question: %@", [questionData hexString]);

    NSMutableString * urlString = [self.address mutableCopy];
    if ([urlString containsString:@"?"]) {
        [urlString appendFormat:@"&dns=%@", [questionData base64URLEncodedValue]];
    } else {
        [urlString appendFormat:@"?dns=%@", [questionData base64URLEncodedValue]];
    }

    PDebug(@"HTTP GET %@", urlString);

    NSURL * serverURL = [[NSURL alloc] initWithString:urlString];
    if (serverURL == nil) {
        completed(nil, MAKE_ERROR(1, @"Bad DNS over HTTPS URL"));
        return;
    }

    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:serverURL];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/dns-message" forHTTPHeaderField:@"Accept"];
    [request setValue:@"0" forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"DNSKit DNS-Inspector/%@ +https://dns-inspector.com/" forHTTPHeaderField:@"User-Agent"];

    NSURLSessionConfiguration * sessionConfiguration = [[NSURLSessionConfiguration defaultSessionConfiguration] copy];
    sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData; // Prohibit caching
    sessionConfiguration.timeoutIntervalForResource = (NSTimeInterval)5; // 5 second timeout
    NSURLSession * urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];

    NSURLSessionDataTask * task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * urlResponse, NSError * error) {
        if (error != nil) {
            completed(nil, error);
            return;
        }
        if (urlResponse == nil) {
            completed(nil, MAKE_ERROR(1, @"Bad response"));
            return;
        }
        if (data == nil) {
            completed(nil, MAKE_ERROR(1, @"Bad response"));
            return;
        }
        NSHTTPURLResponse * response = (NSHTTPURLResponse *)urlResponse;
        if (response.statusCode != 200) {
            NSString * errorString = [NSString stringWithFormat:@"HTTP Error %i", (int)response.statusCode];
            completed(nil, MAKE_ERROR(1, errorString));
            return;
        }
        if (data.length > 512) {
            completed(nil, MAKE_ERROR(1, @"Bad response"));
            return;
        }
        NSString * contentType = [response valueForHeader:@"Content-Type"];
        if (contentType == nil) {
            completed(nil, MAKE_ERROR(1, @"Bad response"));
            return;
        }
        if (![contentType.lowercaseString isEqualToString:@"application/dns-message"]) {
            completed(nil, MAKE_ERROR(1, @"Bad response"));
            return;
        }

        PDebug(@"Answer: %@", [data hexString]);

        NSError * replyError;
        DNSMessage * reply = [DNSMessage messageFromData:data error:&replyError];
        if (replyError != nil) {
            completed(nil, replyError);
            return;
        }

        completed(reply, nil);
        return;
    }];
    [task resume];
}

@end
