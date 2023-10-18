#import "NSData+Base64URL.h"

@implementation NSData (Base64URL)

- (NSString *) base64URLEncodedValue {
    NSString * value = [self base64EncodedStringWithOptions:0];
    value = [value stringByReplacingOccurrencesOfString:@"=" withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    value = [value stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return value;
}

@end
