#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSRecordData : NSObject

@property (strong, nonatomic, nonnull, readonly) NSData * recordValue;
- (NSString * _Nonnull) hexValue;

@end

NS_ASSUME_NONNULL_END
