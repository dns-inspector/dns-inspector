#import "WHOISClient.h"
#import "WHOISClient+Private.h"
#import <netdb.h>
#import <sys/types.h>
#import <sys/socket.h>

@implementation WHOISClient

+ (void) lookupDomain:(NSString *)domain completed:(void (^)(NSString *, NSError *))completed {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSString * bareDomain;
        NSString * whoisHost = [WHOISClient getLookupHostForDomain:domain bareDomain:&bareDomain];
        if (whoisHost == nil) {
            PError(@"Invalid domain for WHOIS lookup: %@", domain);
            completed(nil, MAKE_ERROR(-1, @"TLD does not support WHOIS"));
            return;
        }
        [WHOISClient lookupDomain:bareDomain onServer:whoisHost depth:1 completed:completed];
    });
}

+ (void) lookupDomain:(NSString *)domain onServer:(NSString *)server depth:(int)depth completed:(void (^)(NSString *, NSError *))completed {
    PDebug(@"Performing WHOIS lookup for domain %@ on server %@", domain, server);
    struct addrinfo hints, *res;
    int sockfd, status;

    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    if ((status = getaddrinfo([server cStringUsingEncoding:NSASCIIStringEncoding], "43", &hints, &res)) != 0) {
        NSString * error = [NSString stringWithFormat:@"DNS %s", gai_strerror(status)];
        PError(@"%@", error);
        completed(nil, MAKE_ERROR(-1, error));
        return;
    }

    sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);

    if (connect(sockfd, res->ai_addr, res->ai_addrlen) != 0) {
        NSString * error = [NSString stringWithFormat:@"Error connecting to WHOIS server %s", strerror(errno)];
        PError(@"%@", error);
        completed(nil, MAKE_ERROR(-1, error));
        return;
    }

    NSString * query = [NSString stringWithFormat:@"%@\r\n", domain];

    size_t wrote = send(sockfd, [query dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:true].bytes, query.length, 0);
    if (wrote == -1) {
        NSString * error = [NSString stringWithFormat:@"Error connecting to WHOIS server %s", strerror(errno)];
        PError(@"%@", error);
        completed(nil, MAKE_ERROR(-1, error));
        return;
    } else if (wrote != query.length) {
        errno = ENOMEM;
        NSString * error = [NSString stringWithFormat:@"Error connecting to WHOIS server %s", strerror(errno)];
        PError(@"%@", error);
        completed(nil, MAKE_ERROR(-1, error));
        return;
    }

    // We don't have a way of knowing the size of the incoming message, so we'll just assume it's less than 4KiB
    // and if it's over that then it's just text data so it's not the end of the world if it's truncated.
    char * buf[4*1024];
    size_t read = recv(sockfd, buf, 4*1024, 0);
    close(sockfd);

    if (read == 0) {
        NSString * error = @"No data returned from WHOIS server";
        PError(@"%@", error);
        completed(nil, MAKE_ERROR(-1, error));
        return;
    }

    NSData * responseBytes = [NSData dataWithBytes:buf length:read];
    NSString * response = [NSString stringWithUTF8String:responseBytes.bytes];

    // Check if there is a server we should follow to
    if (![response containsString:@"Registrar WHOIS Server: "]) {
        completed(response, nil);
        return;
    }

    // Need to continue to next WHOIS server
    NSString * nextServer;
    for (NSString * line in [response componentsSeparatedByString:@"\n"]) {
        if (![line containsString:@"Registrar WHOIS Server: "]) {
            continue;
        }

        NSArray<NSString *> * parts = [line componentsSeparatedByString:@": "];
        if (parts.count != 2) {
            PWarn(@"Unknown format of registrar WHOIS server line: %@", line);
            break;
        }

        nextServer = parts[1];
        if ([nextServer characterAtIndex:nextServer.length-1] == '\r') {
            nextServer = [nextServer substringToIndex:nextServer.length-1];
        }

        if ([nextServer hasPrefix:@"https://"]) {
            nextServer = [nextServer stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        } else if ([nextServer hasPrefix:@"http://"]) {
            nextServer = [nextServer stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        }

        break;
    }

    if (nextServer == nil) {
        completed(response, nil);
        return;
    }

    if ([nextServer.lowercaseString isEqualToString:server.lowercaseString]) {
        completed(response, nil);
        return;
    }

    if (depth > 10) {
        PError(@"Aborting WHOIS request, too many redirects");
        NSString * error = @"Too many redirects";
        PError(@"%@", error);
        completed(nil, MAKE_ERROR(-1, error));
        return;
    }

    return [WHOISClient lookupDomain:domain onServer:nextServer depth:depth+1 completed:completed];
}

+ (NSString *) getLookupHostForDomain:(NSString *)domain bareDomain:(NSString **)bareDomain {
    if (domain.length == 0 || domain.length > 250) {
        return nil;
    }

    NSString * input = [domain lowercaseString];
    if ([input characterAtIndex:input.length-1] == '.') {
        input = [input substringToIndex:input.length-1];
    }

    NSMutableArray<NSString *> * parts = [[NSMutableArray alloc] initWithArray:[input componentsSeparatedByString:@"."]];
    const char * tld = [parts[parts.count-1] cStringUsingEncoding:NSASCIIStringEncoding];
    size_t tldLen = strnlen(tld, 250);

    // First check if the domain uses a gTLD. gTLD's are always one-level
    int i;
    size_t itldLen;
    for (i = 0; new_gtlds[i]; i++) {
        itldLen = strlen(new_gtlds[i]);

        if (tldLen != itldLen) {
            continue;
        }

        if (strncmp(tld, new_gtlds[i], tldLen) == 0) {
            *bareDomain = [NSString stringWithFormat:@"%@.%s", parts[parts.count-2], tld];
            return [[NSString alloc] initWithFormat:@"whois.nic.%s", tld];
        }
    }

    // Next iterate through each part of the input domain name, cutting off one domain each time until we find a match
    // or we've run out of domains.
    while (true) {
        [parts removeObjectAtIndex:0];
        if (parts.count == 0) {
            break;
        }

        tld = [[NSString stringWithFormat:@".%@", [parts componentsJoinedByString:@"."]] cStringUsingEncoding:NSASCIIStringEncoding];
        tldLen = strnlen(tld, 250);

        for (i = 0; tld_serv[i]; i += 2) {
            itldLen = strlen(tld_serv[i]);

            if (tldLen != itldLen) {
                continue;
            }

            if (strncmp(tld, tld_serv[i], tldLen) == 0) {
                NSUInteger tldParts = [[NSString stringWithCString:tld + 1 encoding:NSASCIIStringEncoding] componentsSeparatedByString:@"."].count;
                NSArray<NSString *> * inputParts = [input componentsSeparatedByString:@"."];
                *bareDomain = [[inputParts subarrayWithRange:NSMakeRange(inputParts.count - tldParts - 1, tldParts + 1)] componentsJoinedByString:@"."];
                return [NSString stringWithUTF8String:tld_serv[i + 1]];
            }
        }
    }

    PError(@"No WHOIS server found for %@", input);
    return nil;
}

@end
