#import "DNSAnswer.h"
#import "DNSAnswer+Private.h"
#import "DNSRecordData+Private.h"
#import "NSData+HexString.h"
#import "DNSName.h"
#import "NSArray+Subindex.h"

@implementation DNSAnswer

- (DNSAnswer *) initWithName:(NSString *)name recordType:(DNSRecordType)recordType recordClass:(DNSRecordClass)recordClass ttlSeconds:(NSUInteger)ttlSeconds data:(NSData *)data {
    self = [super self];
    self.name = name;
    self.recordType = recordType;
    self.recordClass = recordClass;
    self.ttlSeconds = ttlSeconds;
    self.data = [[DNSRecordData alloc] initWithRecordValue:data];

    return self;
}

- (NSString *) description {
    return [self stringValue];
}

- (NSString *) stringValue {
    return [NSString stringWithFormat:@"%@ %i %@ %@ %@", self.name, (int)self.ttlSeconds, [DNSAnswer stringForRecordClass:self.recordClass], [DNSAnswer stringForRecordType:self.recordType], self.data.stringValue];
}

+ (NSString * _Nullable) stringForRecordType:(DNSRecordType)rtype {
    switch (rtype) {
        case DNSRecordTypeA:
            return @"A";
        case DNSRecordTypeNS:
            return @"NS";
        case DNSRecordTypeCNAME:
            return @"CNAME";
        case DNSRecordTypeAAAA:
            return @"AAAA";
        case DNSRecordTypeAPL:
            return @"APL";
        case DNSRecordTypeSRV:
            return @"SRV";
        case DNSRecordTypeTXT:
            return @"TXT";
        case DNSRecordTypeMX:
            return @"MX";
        case DNSRecordTypePTR:
            return @"PTR";
        case DNSRecordTypeDS:
            return @"DS";
        case DNSRecordTypeRRSIG:
            return @"RRSIG";
        case DNSRecordTypeDNSKEY:
            return @"DNSKEY";
    }

    return nil;
}

+ (NSString * _Nullable) stringForRecordClass:(DNSRecordClass)rclass {
    switch (rclass) {
        case DNSRecordClassIN:
            return @"IN";
        case DNSRecordClassCS:
            return @"CS";
        case DNSRecordClassCH:
            return @"CH";
        case DNSRecordClassHS:
            return @"HS";
    }

    return nil;
}

- (NSData *) rawSignatureData:(DNSRRSIGRecordData *)rrsig {
    NSArray<NSString *> * labels = [DNSName splitName:self.name];
    NSString * name;

    // wildcards
    if (labels.count != rrsig.labelCount) {
        name = [NSString stringWithFormat:@"*.%@.", [[labels subarrayFromIndex:labels.count-rrsig.labelCount] componentsJoinedByString:@"."]];
    } else {
        name = self.name;
    }

    // nornmalize name
    name = [name lowercaseString];
    if ([name characterAtIndex:name.length-1] != '.') {
        name = [NSString stringWithFormat:@"%@.", name];
    }

    NSMutableData * data = [NSMutableData new];
    NSError * nameError;
    NSData * nameData = [DNSName stringToDNSName:name error:&nameError];
    [data appendData:nameData];
    uint16_t rtype = htons(self.recordType);
    uint16_t rclass = htons(self.recordClass);
    uint32_t ttl = htonl(self.ttlSeconds);
    uint16_t dlen = htons(self.dataLength);
    [data appendBytes:&rtype length:2];
    [data appendBytes:&rclass length:2];
    [data appendBytes:&ttl length:4];
    [data appendBytes:&dlen length:2];
    [data appendData:self.data.recordValue];

    return data;
}

+ (int) compareLeft:(DNSAnswer *)left withRight:(DNSAnswer *)right {
    return memcmp(left.data.recordValue.bytes, right.data.recordValue.bytes, left.data.recordValue.length);
}

@end
