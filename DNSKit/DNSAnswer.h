#import <Foundation/Foundation.h>

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

/// The data of this record. For A and AAAA this will be an ASCII string representing the human-readable IP address.
@property (strong, nonatomic, nonnull) NSData * data;

/// Get a human readable description of the data
- (NSString * _Nonnull) dataDescription;

@end

NS_ASSUME_NONNULL_END
