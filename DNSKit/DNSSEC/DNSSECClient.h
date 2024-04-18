#import <Foundation/Foundation.h>
#import "DNSClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSSECClient : NSObject

+ (void) authenticateMessage:(DNSMessage *)message usingClient:(DNSClient *)client withResult:(void (^)(NSError *))completed;
+ (NSError *) validateAnswers:(NSArray<DNSAnswer *> *)answers withSignature:(DNSAnswer *)rrsigAnswer againstKey:(DNSAnswer *)dnskeyAnswer;

@end

NS_ASSUME_NONNULL_END
