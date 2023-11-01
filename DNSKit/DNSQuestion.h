#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Describes the structure for a DNS question
@interface DNSQuestion : NSObject

- (DNSQuestion * _Nonnull) initWithName:(NSString * _Nonnull)name recordType:(DNSRecordType)recordType recordClass:(DNSRecordClass)recordClass;

/// The resource name
@property (strong, nonatomic, nonnull) NSString * name;

/// The question record type
@property (nonatomic) DNSRecordType recordType;

/// The question class
@property (nonatomic) DNSRecordClass recordClass;

@end

NS_ASSUME_NONNULL_END
