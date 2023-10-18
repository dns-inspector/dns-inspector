#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSName : NSObject

+ (NSData *) stringToDNSName:(NSString *)name error:(NSError **)error;
+ (NSString *) readDNSName:(NSData *)data startIndex:(int)startIdx dataIndex:(int * _Nullable)dataIndex error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
