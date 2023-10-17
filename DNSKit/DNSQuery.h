#import <Foundation/Foundation.h>
#import "DNSKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSQuery : NSObject

@property (nonatomic) DNSServerType serverType;
@property (strong, nonatomic, nonnull) NSString * serverAddress;
@property (nonatomic) DNSRecordType recordType;
@property (strong, nonatomic, nonnull) NSString * name;

+ (DNSQuery * _Nullable) queryWithServerType:(DNSServerType)serverType serverAddress:(NSString * _Nonnull)serverAddress recordType:(DNSRecordType)recordType name:(NSString * _Nonnull)name error:(NSError * _Nullable * _Nonnull)error;
- (void) execute:(void (^_Nonnull)(DNSMessage * _Nullable, NSError * _Nullable))completed;

@end

NS_ASSUME_NONNULL_END
