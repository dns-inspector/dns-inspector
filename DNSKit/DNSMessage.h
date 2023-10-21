#import <Foundation/Foundation.h>
#import <DNSKit/DNSQuestion.h>
#import <DNSKit/DNSAnswer.h>

NS_ASSUME_NONNULL_BEGIN

/// Class for a DNS message
@interface DNSMessage : NSObject

/// The ID number
@property (nonatomic) NSUInteger idNumber;

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
