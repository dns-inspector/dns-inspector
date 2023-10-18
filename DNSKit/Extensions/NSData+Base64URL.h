#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Base64URL)

/// Returns a Base64 URL encoded string representing the data
- (NSString *) base64URLEncodedValue;

@end

NS_ASSUME_NONNULL_END
