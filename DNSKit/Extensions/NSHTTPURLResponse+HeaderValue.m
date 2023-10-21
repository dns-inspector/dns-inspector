#import "NSHTTPURLResponse+HeaderValue.h"

@implementation NSHTTPURLResponse (HeaderValue)

- (NSString *) valueForHeader:(NSString *)headerName {
    NSDictionary * headers = self.allHeaderFields;

    for (NSString * key in headers.allKeys) {
        if ([headerName.lowercaseString isEqualToString:key.lowercaseString]) {
            return headers[key];
        }
    }

    return nil;
}

@end
