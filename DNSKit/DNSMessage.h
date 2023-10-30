#import <Foundation/Foundation.h>
#import <DNSKit/DNSQuestion.h>
#import <DNSKit/DNSAnswer.h>

NS_ASSUME_NONNULL_BEGIN

/// Class for a DNS message
@interface DNSMessage : NSObject

/// The ID number
@property (nonatomic) NSUInteger idNumber;

/// Is recursion desired
@property (nonatomic) BOOL recursionDesired;

/// Is this message truncated
@property (nonatomic) BOOL truncated;

/// Is this answer authoritative
@property (nonatomic) BOOL authoritativeAnswer;

/// The operation code
@property (nonatomic) DNSOperationCode operationCode;

/// If this message is a query (true) or a reply (false)
@property (nonatomic) BOOL isQuery;

/// The response code
@property (nonatomic) DNSResponseCode responseCode;

/// DNS questions
@property (strong, nonatomic, nullable) NSArray<DNSQuestion *> * questions;

/// DNS answers
@property (strong, nonatomic, nullable) NSArray<DNSAnswer *> * answers;

/// Decode a DNS message from the data object.
+ (DNSMessage * _Nullable) messageFromData:(NSData * _Nonnull)data error:(NSError * _Nullable * _Nonnull)error;

/// Return the DNS message data
- (NSData * _Nullable) messageDataError:(NSError * _Nullable * _Nonnull)error;

@end

NS_ASSUME_NONNULL_END
