
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DNSRecordType) {
    DNSRecordTypeA = 1,
    DNSRecordTypeAAAA = 28,
    DNSRecordTypeAPL = 42,
    DNSRecordTypeSRV = 33,
    DNSRecordTypeTXT = 16,
    DNSRecordTypeMX = 15,
    DNSRecordTypePTR = 12,
};

typedef NS_ENUM(NSUInteger, DNSServerType) {
    DNSServerTypeDNS = 1,
    DNSServerTypeHTTPS = 2,
    DNSServerTypeTLS = 3,
};

NS_ASSUME_NONNULL_END
