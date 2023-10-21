#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Describes the structure for a DNS question
@interface DNSQuestion : NSObject

/// The resource name
@property (strong, nonatomic, nonnull) NSString * name;

/// The question record type
@property (nonatomic) DNSRecordType questionType;

/// The question class
@property (nonatomic) NSUInteger questionClass;

@end

NS_ASSUME_NONNULL_END
