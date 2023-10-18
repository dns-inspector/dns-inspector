#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSAnswer : NSObject

@property (strong, nonatomic, nonnull) NSString * name;
@property (nonatomic) DNSRecordType recordType;
@property (nonatomic) NSUInteger recordClass;
@property (nonatomic) NSUInteger ttlSeconds;
@property (strong, nonatomic, nonnull) NSData * data;

@end

NS_ASSUME_NONNULL_END
