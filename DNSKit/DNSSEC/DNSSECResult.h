#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSSECResult : NSObject

@property (nonatomic) BOOL signatureVerified;
@property (strong, nonatomic, nullable) NSError * signatureError;
@property (nonatomic) BOOL chainTrusted;
@property (strong, nonatomic, nullable) NSError * chainError;

@end

NS_ASSUME_NONNULL_END
