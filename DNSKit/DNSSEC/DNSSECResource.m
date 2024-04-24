#import "DNSSECResource.h"

@implementation DNSSECResource

- (NSString *) debugDescription {
    return [self description];
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%@: %i keys, %@ ds", self.name, (int)self.dnsKeys.count, (self.ds == nil ? @"without" : @"with")];
}

@end
