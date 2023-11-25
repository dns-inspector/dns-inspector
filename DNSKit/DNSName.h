#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSName : NSObject

/// Converts the given domain name into an encoded DNS name object.
///
/// For example, given "www.example.com" returns [3]www[7]example[3]com[0]
///
/// - Parameters:
///   - name: The domain name
///   - error: Populated with an error if the given name is not valid
+ (NSData * _Nullable) stringToDNSName:(NSString * _Nonnull)name error:(NSError * _Nullable * _Nullable)error;

/// Given an entire DNS message, read a domain name starting from the specified index. Accounts for DNS compression.
///
/// - Parameters:
///   - data: Data representing an entire DNS message
///   - startIdx: The start index of where to begin reading a DNS domain name
///   - dataIndex: Populated with the index where the next byte of data is located following the DNS domain name
///   - error: Populated with an error if the given name is not valid
+ (NSString * _Nullable) readDNSName:(NSData * _Nonnull)data startIndex:(int)startIdx dataIndex:(int * _Nullable)dataIndex error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
