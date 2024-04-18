#import <Foundation/Foundation.h>
#import "DNSDNSKEYRecordData.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSDNSKEYRecordData (Private)

- (SecKeyRef) parsePublicKey:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
