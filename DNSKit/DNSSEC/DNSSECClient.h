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
+ (void) authenticateMessage:(DNSMessage *)message usingClient:(DNSClient *)client withResult:(void (^)(DNSSECResult *))completed;

/// Validate the set of DNS Answers against the signature and key
/// - Parameters:
///   - answers: The set of answers, exclusing the RRSIG answer
///   - rrsigAnswer: The RRSIG answer associated for the set of answers
///   - dnskeyAnswer: The DNSKEY used to sign the RRSIG
/// - Returns: An error with a code from DNSSECError
+ (NSError *) validateAnswers:(NSArray<DNSAnswer *> *)answers withSignature:(DNSAnswer *)rrsigAnswer againstKey:(DNSAnswer *)dnskeyAnswer;

@end

NS_ASSUME_NONNULL_END
