#import <Foundation/Foundation.h>
#import "DNSClient.h"

NS_ASSUME_NONNULL_BEGIN

/// DNSSEC client
@interface DNSSECClient : NSObject

/// Authenticate that the message was signed with a fully valid chain, going up to the DNS root.
/// - Parameters:
///   - message: The message to authenticate
///   - client: The DNS client to use for queries
///   - completed: Called when authentication has completed
+ (void) authenticateMessage:(DNSMessage *)message usingClient:(DNSClient *)client withResult:(void (^)(NSError *))completed;

/// Validates that the DNS message contains signed data using the given DNS key
/// - Parameters:
///   - message: The message. Must contain records and a matching RRSIG
///   - dnskeyAnswer: The DNSKEY used to sign the RRSIG
/// - Returns: An error with a code from DNSSECError
+ (NSError *) validateMessage:(DNSMessage *)message againstKey:(DNSAnswer *)dnskeyAnswer;

/// Validate the set of DNS Answers against the signature and key
/// - Parameters:
///   - answers: The set of answers, exclusing the RRSIG answer
///   - rrsigAnswer: The RRSIG answer associated for the set of answers
///   - dnskeyAnswer: The DNSKEY used to sign the RRSIG
/// - Returns: An error with a code from DNSSECError
+ (NSError *) validateAnswers:(NSArray<DNSAnswer *> *)answers withSignature:(DNSAnswer *)rrsigAnswer againstKey:(DNSAnswer *)dnskeyAnswer;

@end

NS_ASSUME_NONNULL_END
