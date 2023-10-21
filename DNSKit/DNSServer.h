#import <Foundation/Foundation.h>
#import "DNSMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSServer : NSObject

@property (strong, nonatomic) NSString * address;

+ (DNSServer *) serverWithAddress:(NSString *)address error:(NSError **)error;
- (void) sendMessage:(DNSMessage *)message gotReply:(void (^)(DNSMessage *, NSError *))completed;

@end

NS_ASSUME_NONNULL_END
