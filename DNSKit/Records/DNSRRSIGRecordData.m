#import "DNSRRSIGRecordData.h"
#import "DNSRecordData+Private.h"
#import "DNSName.h"
#import "NSData+ByteAtIndex.h"

@interface DNSRRSIGRecordData()

@property (nonatomic, readwrite) DNSRecordType typeCovered;
@property (nonatomic, readwrite) DNSSECAlgorithm algorithm;
@property (nonatomic, readwrite) NSUInteger labelCount;
@property (nonatomic, readwrite) NSUInteger ttlSeconds;
@property (strong, nonatomic, readwrite, nonnull) NSDate * signatureNotAfter;
@property (strong, nonatomic, readwrite, nonnull) NSDate * signatureNotBefore;
@property (nonatomic, readwrite) NSUInteger keyTag;
@property (strong, nonatomic, readwrite, nonnull) NSString * signerName;
@property (strong, nonatomic, readwrite, nonnull) NSData * signature;

@end

@implementation DNSRRSIGRecordData

- (id) initWithRecordValue:(NSData *)value {
    self = [super initWithRecordValue:value];

    uint16_t typeCovered = ntohs(*(uint16_t *)[self.recordValue subdataWithRange:NSMakeRange(0, 2)].bytes);
    uint8_t algorithm = [self.recordValue byteAtIndex:2];
    uint8_t labelCount = [self.recordValue byteAtIndex:3];
    uint32_t ttl = ntohl(*(uint32_t *)[self.recordValue subdataWithRange:NSMakeRange(4, 4)].bytes);
    uint32_t notAfter = ntohl(*(uint32_t *)[self.recordValue subdataWithRange:NSMakeRange(8, 4)].bytes);
    uint32_t notBefore = ntohl(*(uint32_t *)[self.recordValue subdataWithRange:NSMakeRange(12, 4)].bytes);
    uint16_t keyTag = ntohs(*(uint16_t *)[self.recordValue subdataWithRange:NSMakeRange(16, 2)].bytes);

    int dataIndex;
    NSError * nameError;
    NSString * signerName = [DNSName readDNSName:self.recordValue startIndex:18 dataIndex:&dataIndex error:&nameError];
    if (nameError != nil) {
        signerName = @"__ERROR";
    }

    NSData * signature = [self.recordValue subdataWithRange:NSMakeRange(dataIndex, self.recordValue.length-dataIndex)];

    self.typeCovered = (DNSRecordType)typeCovered;
    self.algorithm = (DNSSECAlgorithm)algorithm;
    self.labelCount = (NSUInteger)labelCount;
    self.ttlSeconds = (NSUInteger)ttl;
    self.signatureNotAfter = [[NSDate alloc]initWithTimeIntervalSince1970:notAfter];
    self.signatureNotBefore = [[NSDate alloc]initWithTimeIntervalSince1970:notBefore];
    self.keyTag = (NSUInteger)keyTag;
    self.signerName = signerName;
    self.signature = signature;

    return self;
}

@end
