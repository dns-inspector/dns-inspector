#import <Foundation/Foundation.h>
#import "DNSMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSClient : NSObject

@property (strong, nonatomic) NSString * address;

+ (DNSClient *) serverWithAddress:(NSString *)address error:(NSError **)error;
- (void) sendMessage:(DNSMessage *)message gotReply:(void (^)(DNSMessage *, NSError *))completed;
- (void) authenticateMessage:(DNSMessage *)message withResult:(void (^)(DNSSECResult *))completed;

@end

NS_ASSUME_NONNULL_END
