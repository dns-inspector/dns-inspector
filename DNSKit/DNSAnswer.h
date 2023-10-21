#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Describes the structure of a DNS answer
@interface DNSAnswer : NSObject

/// The name of the resource record
@property (strong, nonatomic, nonnull) NSString * name;

/// The record type
@property (nonatomic) DNSRecordType recordType;

/// The record class
@property (nonatomic) NSUInteger recordClass;

/// The record time to live in seconds
@property (nonatomic) NSUInteger ttlSeconds;

/// The data of this record. For A and AAAA this will be an ASCII string representing the human-readable IP address.
@property (strong, nonatomic, nonnull) NSData * data;

@end

NS_ASSUME_NONNULL_END
