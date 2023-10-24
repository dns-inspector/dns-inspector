#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DNSRecordType) {
    DNSRecordTypeA = 1,
    DNSRecordTypeCNAME = 5,
    DNSRecordTypeAAAA = 28,
    DNSRecordTypeAPL = 42,
    DNSRecordTypeSRV = 33,
    DNSRecordTypeTXT = 16,
    DNSRecordTypeMX = 15,
    DNSRecordTypePTR = 12,
};

typedef NS_ENUM(NSUInteger, DNSRecordClass) {
    DNSRecordClassIN = 1,
    DNSRecordClassCS = 2,
    DNSRecordClassCH = 3,
    DNSRecordClassHS = 4,
};

typedef NS_ENUM(NSUInteger, DNSServerType) {
    DNSServerTypeDNS = 1,
    DNSServerTypeHTTPS = 2,
    DNSServerTypeTLS = 3,
};

typedef NS_ENUM(NSUInteger, DNSResponseCode) {
    /// Default value to indicate no error
    DNSResponseCodeSuccess = 0,

    DNSResponseCodeFORMERR = 1,
    DNSResponseCodeSERVFAIL = 2,
    DNSResponseCodeNXDOMAIN = 3,
    DNSResponseCodeNOTIMP = 4,
    DNSResponseCodeREFUSED = 5,
    DNSResponseCodeYXDOMAIN = 6,
    DNSResponseCodeXRRSET = 7,
    DNSResponseCodeNOTAUTH = 8,
    DNSResponseCodeNOTZONE = 9,
};

NS_ASSUME_NONNULL_END
