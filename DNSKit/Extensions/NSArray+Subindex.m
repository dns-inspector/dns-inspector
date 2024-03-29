#import "NSArray+Subindex.h"

@implementation NSArray (Subindex)

- (NSArray<id> *) subarrayToIndex:(NSUInteger)index {
    if (index > self.count - 1) {
        assert("index out of bounds");
    }

    return [self subarrayWithRange:NSMakeRange(0, index)];
}

- (NSArray<id> *) subarrayFromIndex:(NSUInteger)index {
    if (index > self.count - 1) {
        assert("index out of bounds");
    }

    return [self subarrayWithRange:NSMakeRange(index, self.count-index)];
}

@end
