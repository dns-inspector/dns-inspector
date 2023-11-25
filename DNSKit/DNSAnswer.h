#import <Foundation/Foundation.h>
#import "DNSRecordData.h"

NS_ASSUME_NONNULL_BEGIN

/// Describes the structure of a DNS answer
@interface DNSAnswer : NSObject

- (DNSAnswer * _Nonnull) initWithName:(NSString * _Nonnull)name recordType:(DNSRecordType)recordType recordClass:(DNSRecordClass)recordClass ttlSeconds:(NSUInteger)ttlSeconds data:(NSData * _Nonnull)data;

/// The name of the resource record
@property (strong, nonatomic, nonnull) NSString * name;

/// The record type
@property (nonatomic) DNSRecordType recordType;

/// The record class
@property (nonatomic) DNSRecordClass recordClass;

/// The record time to live in seconds
@property (nonatomic) NSUInteger ttlSeconds;

/// The data object for this answer. Cast this to the specific DNSRecordData subclass based on the record type.
@property (strong, nonatomic, nonnull) DNSRecordData * data;

@end

NS_ASSUME_NONNULL_END
