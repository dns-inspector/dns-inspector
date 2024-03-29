#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (Subindex)

- (NSArray<ObjectType> *) subarrayToIndex:(NSUInteger)index;
- (NSArray<ObjectType> *) subarrayFromIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
