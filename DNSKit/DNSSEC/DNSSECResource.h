#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSSECResource : NSObject

@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSArray<DNSDNSKEYRecordData *> * keys;
@property (strong, nonatomic) DNSRRSIGRecordData * rrsig;

@end

NS_ASSUME_NONNULL_END
