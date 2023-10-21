#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSHTTPURLResponse (HeaderValue)

- (NSString * _Nullable) valueForHeader:(NSString * _Nonnull)headerName;

@end

NS_ASSUME_NONNULL_END
