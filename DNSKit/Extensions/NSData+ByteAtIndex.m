#import "NSData+ByteAtIndex.h"

@implementation NSData (HexString)

- (char) byteAtIndex:(NSUInteger)index {
    char buf;
    [self getBytes:&buf range:NSMakeRange(index, 1)];
    return buf;
}

@end
