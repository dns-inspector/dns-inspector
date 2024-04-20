#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DNSRecordType) {
    DNSRecordTypeA = 1,
    DNSRecordTypeNS = 2,
    DNSRecordTypeCNAME = 5,
    DNSRecordTypeAAAA = 28,
    DNSRecordTypeAPL = 42,
    DNSRecordTypeSRV = 33,
    DNSRecordTypeTXT = 16,
    DNSRecordTypeMX = 15,
    DNSRecordTypePTR = 12,
    DNSRecordTypeDS = 43,
    DNSRecordTypeRRSIG = 46,
    DNSRecordTypeDNSKEY = 48,
};

typedef NS_ENUM(NSUInteger, DNSRecordClass) {
    DNSRecordClassIN = 1,
    DNSRecordClassCS = 2,
    DNSRecordClassCH = 3,
    DNSRecordClassHS = 4,
};

typedef NS_ENUM(NSUInteger, DNSClientType) {
    DNSClientTypeDNS = 1,
    DNSClientTypeHTTPS = 2,
    DNSClientTypeTLS = 3,
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

typedef NS_ENUM(NSUInteger, DNSOperationCode) {
    DNSOperationCodeQuery = 0,
    DNSOperationCodeIQuery = 1,
    DNSOperationCodeStatus = 2,
    DNSOperationCodeNotify = 4,
    DNSOperationCodeUpdate = 5,
};

typedef NS_ENUM(NSUInteger, DNSSECAlgorithm) {
    DNSSECAlgorithmECDSAP384_SHA384 = 14,
    DNSSECAlgorithmECDSAP256_SHA256 = 13,
    DNSSECAlgorithmRSA_SHA512 = 10,
    DNSSECAlgorithmRSA_SHA256 = 8,
    DNSSECAlgorithmRSA_SHA1 = 5,
};

typedef NS_ENUM(NSUInteger, DNSSECDigest) {
    DNSSECDigestSHA1 = 1,
    DNSSECDigestSHA256 = 2,
    DNSSECDigestSHA384 = 4,
};

/// Error codes from DNSSEC message authentication
typedef NS_ENUM(NSUInteger, DNSSECError) {
    /// No signatures were found on the DNS message
    DNSSECErrorNoSignatures = 1,
    /// The algorithm used is not supported by DNSKit
    DNSSECErrorUnsupportedAlgorithm = 2,
    /// One or more domain did not produce signing keys
    DNSSECErrorMissingKeys = 3,
    /// The key signing key for the root domain was not recognized and is untrusted
    DNSSECErrorUntrustedRootSigningKey = 4,
    /// One or more signatures for resource records failed cryptographic validation
    DNSSECSignatureFailed = 5,
    /// One or more aspects of the response is invalid
    DNSSECInvalidResponse = 6,
    /// The signing key provided was invalid
    DNSSECBadSigningKey = 7,
};

NS_ASSUME_NONNULL_END
