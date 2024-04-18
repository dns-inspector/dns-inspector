#import <Foundation/Foundation.h>

@interface NSData (HexString)

- (NSString *) hexString;
+ (NSData *) fromHexString:(NSString *)hexString;

@end
