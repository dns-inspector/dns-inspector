#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSQuestion : NSObject

@property (strong, nonatomic, nonnull) NSString * name;
@property (nonatomic) DNSRecordType questionType;
@property (nonatomic) NSUInteger questionClass;

@end

NS_ASSUME_NONNULL_END
