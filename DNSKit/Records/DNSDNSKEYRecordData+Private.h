#import <Foundation/Foundation.h>
#import "DNSDNSKEYRecordData.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSDNSKEYRecordData (Private)

- (SecKeyRef) parsePublicKey:(NSError **)error;
- (NSData *) hashWithOwnerName:(NSString *)ownerName algorithm:(DNSSECDigest)algorithm;

@end

NS_ASSUME_NONNULL_END
