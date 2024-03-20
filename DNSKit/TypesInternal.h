#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct _DNS_HEADER
{
    unsigned short transactionId;
    unsigned char recursionDesired:1;
    unsigned char truncation:1;
    unsigned char authoritativeAnswer:1;
    unsigned char opcode:4;
    unsigned char isResponse:1;
    unsigned char responseCode:4;
    unsigned char checkingDisabled:1;
    unsigned char authenticatedData:1;
    unsigned char reserved:1;
    unsigned char recursionAvailable:1;
    unsigned short questionCount;
    unsigned short answerCount;
    unsigned short nameserverCount;
    unsigned short additionalCount;
} DNS_HEADER;

NS_ASSUME_NONNULL_END
