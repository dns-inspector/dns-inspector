#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSRecordData : NSObject

/// The raw data of this record
@property (strong, nonatomic, nonnull, readonly) NSData * recordValue;

/// A hex string representation of the data value.
- (NSString * _Nonnull) hexValue;

/// A string value representing this data. Safe for human consumption.
- (NSString * _Nullable) stringValue;

@end

NS_ASSUME_NONNULL_END
