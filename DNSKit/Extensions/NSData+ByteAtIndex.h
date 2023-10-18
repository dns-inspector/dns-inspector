#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (ByteAtIndex)

- (char) byteAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
