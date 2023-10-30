#import "DNSMessage.h"
#import "DNSName.h"
#import "NSData+ByteAtIndex.h"
#import "NSData+HexString.h"
#import "TypesInternal.h"
#import <arpa/inet.h>

@implementation DNSMessage

+ (DNSMessage *) messageFromData:(NSData *)data error:(NSError **)error {
    DNSMessage * message = [DNSMessage new];
    NSData * headerBytes = [data subdataWithRange:NSMakeRange(0, sizeof(DNS_HEADER))];
    DNS_HEADER * responseHeader = (DNS_HEADER *)headerBytes.bytes;
    uint16_t responseId = responseHeader->idn;
    uint16_t responseIdH = ntohs(responseId);
    message.idNumber = responseIdH;
    message.responseCode = responseHeader->rd == 1;
    message.truncated = responseHeader->tc == 1;
    message.authoritativeAnswer = responseHeader->aa == 1;
    message.operationCode = (DNSOperationCode)responseHeader->opcode;
    message.isQuery = responseHeader->qr == 1;

    DNSResponseCode rcode = (DNSResponseCode)responseHeader->rcode;
    PDebug(@"Response code %i", (int)rcode);
    message.responseCode = rcode;

    short questionCount = ntohs(responseHeader->qlen);
    short answerCount = ntohs(responseHeader->alen);

    if (questionCount <= 0) {
        PError(@"Unexpected number of questions returned in DNS response: %i", questionCount);
        *error = MAKE_ERROR(1, @"Unexpected number of questions in DNS response");
        return nil;
    }

    NSMutableArray<DNSQuestion *> * questions = [NSMutableArray new];
    int questionsRead = 0;
    int questionStartIndex = sizeof(DNS_HEADER);
    while (questionsRead < questionCount) {
        NSError * nameError;
        int dataIndex = 0;
        NSString * name = [DNSName readDNSName:data startIndex:questionStartIndex dataIndex:&dataIndex error:&nameError];
        if (nameError != nil) {
            PError(@"Invalid DNS name in response: %@", nameError.localizedDescription);
            *error = MAKE_ERROR(1, @"Bad response");
            return nil;
        }
        uint16_t qtype = ntohs(*(uint16_t *)[data subdataWithRange:NSMakeRange(dataIndex, 2)].bytes);
        uint16_t qclass = ntohs(*(uint16_t *)[data subdataWithRange:NSMakeRange(dataIndex+2, 2)].bytes);
        DNSQuestion * question = [DNSQuestion new];
        question.name = name;
        question.recordType = (DNSRecordType)qtype;
        question.recordClass = (DNSRecordClass)qclass;
        [questions addObject:question];
        questionStartIndex = dataIndex+4;
        questionsRead++;
    }
    message.questions = questions;

    int answerStartIndex = questionStartIndex;

    NSMutableArray<DNSAnswer *> * answers = [NSMutableArray new];
    int answersRead = 0;
    while (answersRead < answerCount) {
        NSError * nameError;
        int dataIndex = 0;
        NSString * name = [DNSName readDNSName:data startIndex:answerStartIndex dataIndex:&dataIndex error:&nameError];
        PDebug(@"Answer data starts at offset %i", dataIndex);

        if (nameError != nil) {
            PError(@"Invalid DNS name in response: %@", nameError.localizedDescription);
            *error = MAKE_ERROR(1, @"Bad response");
            return nil;
        }
        if (dataIndex+10 > data.length-1) {
            PError(@"Incomplete DNS response");
            *error = MAKE_ERROR(1, @"Bad response");
            return nil;
        }

        uint16_t rtype = ntohs(*(uint16_t *)[data subdataWithRange:NSMakeRange(dataIndex, 2)].bytes);
        uint16_t rclass = ntohs(*(uint16_t *)[data subdataWithRange:NSMakeRange(dataIndex+2, 2)].bytes);
        uint16_t ttl = ntohs(*(uint16_t *)[data subdataWithRange:NSMakeRange(dataIndex+4, 2)].bytes);
        uint16_t dlen = ntohs(*(uint16_t *)[data subdataWithRange:NSMakeRange(dataIndex+8, 2)].bytes);

        if (rclass != 1) {
            PError(@"Unsupported resource class %i", rclass);
            *error = MAKE_ERROR(1, @"Bad resource class in DNS response");
            return nil;
        }

        if (dlen == 0) {
            PError(@"Empty DNS response");
            *error = MAKE_ERROR(1, @"Empty data in DNS response");
            return nil;
        }
        if (dataIndex+10+dlen > data.length) {
            PError(@"Data length %i exceeds response bytes %lu", dlen, (unsigned long)data.length);
            *error = MAKE_ERROR(1, @"Bad response");
            return nil;
        }

        DNSAnswer * answer = [DNSAnswer new];
        answer.name = name;
        answer.recordType = (DNSRecordType)rtype;
        answer.recordClass = rclass;
        answer.ttlSeconds = ttl;

        NSData * value = [data subdataWithRange:NSMakeRange(dataIndex+10, dlen)];
        PDebug(@"Answer data %@", [value hexString]);
        PDebug(@"Data length %i", dlen);
        answerStartIndex = dataIndex+10+dlen;

        switch ((DNSRecordType)rtype) {
            case DNSRecordTypeA:
            case DNSRecordTypeAAAA: {
                int addrlen = (DNSRecordType)rtype == DNSRecordTypeA ? INET_ADDRSTRLEN : INET6_ADDRSTRLEN;
                int af = (DNSRecordType)rtype == DNSRecordTypeA ? AF_INET : AF_INET6;
                char * addr = malloc(addrlen);
                inet_ntop(af, value.bytes, addr, addrlen);
                answer.data = [[NSString stringWithFormat:@"%s", addr] dataUsingEncoding:NSASCIIStringEncoding];
                [answers addObject:answer];
                break;
            } case DNSRecordTypeCNAME: {
                PDebug(@"Answer for %@ is a CNAME", name);
                NSError * valueError;
                NSString * nextName = [DNSName readDNSName:data startIndex:dataIndex+10 dataIndex:NULL error:&valueError];
                if (valueError != nil) {
                    PError(@"Bad CNAME value: %@", valueError);
                    *error = MAKE_ERROR(1, @"Bad response");
                    return nil;
                }
                answer.data = [nextName dataUsingEncoding:NSASCIIStringEncoding];
                [answers addObject:answer];
                break;
            } default: {
                answer.data = value;
                [answers addObject:answer];
                break;
            }
        }

        answersRead++;
    }

    if (answers.count > 0) {
        message.answers = answers;
    }

    return message;
}

- (NSData *) messageDataError:(NSError **)error {
    NSMutableData * request = [NSMutableData new];

    DNS_HEADER header;

    header.idn = htons(self.idNumber);
    header.rd = 1;
    header.tc = 0;
    header.aa = 0;
    header.opcode = 0;
    header.qr = 0;
    header.rcode = htons(self.responseCode);
    header.cd = 0;
    header.ad = 0;
    header.z = 0;
    header.ra = 0;
    header.qlen = htons(self.questions.count);
    header.alen = htons(self.answers.count);
    header.aulen = 0;
    header.adlen = 0;

    [request appendBytes:&header length:sizeof(DNS_HEADER)];

    for (DNSQuestion * question in self.questions) {
        NSError * nameError;
        NSData * nameBytes = [DNSName stringToDNSName:question.name error:&nameError];
        if (nameError != nil) {
            *error = nameError;
            return nil;
        }
        [request appendData:nameBytes];

        uint16_t qtype = htons(question.recordType);
        [request appendBytes:&qtype length:2];
        uint16_t qclass = htons(question.recordClass);
        [request appendBytes:&qclass length:2];
    }

    return request;
}

@end
