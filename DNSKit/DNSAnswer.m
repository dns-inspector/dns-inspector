#import "DNSAnswer.h"
#import "DNSRecordData+Private.h"
#import "NSData+HexString.h"

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

- (NSString *) stringValue {
    NSString * recordTypeStr;

    switch (self.recordType) {
        case DNSRecordTypeA:
            recordTypeStr = @"A";
            break;
        case DNSRecordTypeNS:
            recordTypeStr = @"NS";
            break;
        case DNSRecordTypeCNAME:
            recordTypeStr = @"CNAME";
            break;
        case DNSRecordTypeAAAA:
            recordTypeStr = @"AAAA";
            break;
        case DNSRecordTypeAPL:
            recordTypeStr = @"APL";
            break;
        case DNSRecordTypeSRV:
            recordTypeStr = @"SRV";
            break;
        case DNSRecordTypeTXT:
            recordTypeStr = @"TXT";
            break;
        case DNSRecordTypeMX:
            recordTypeStr = @"MX";
            break;
        case DNSRecordTypePTR:
            recordTypeStr = @"PTR";
            break;
        default:
            recordTypeStr = @"Unknown";
            break;
    }

    NSString * recordClassStr;

    switch (self.recordClass) {
        case DNSRecordClassIN:
            recordClassStr = @"IN";
            break;
        case DNSRecordClassCS:
            recordClassStr = @"CS";
            break;
        case DNSRecordClassCH:
            recordClassStr = @"CH";
            break;
        case DNSRecordClassHS:
            recordClassStr = @"HS";
            break;
        default:
            recordClassStr = @"UNKNOWN";
            break;
    }

    return [NSString stringWithFormat:@"Type: %@, Class: %@, Name: %@, TTL: %i, Value: %@", recordTypeStr, recordClassStr, self.name, (int)self.ttlSeconds, self.data.stringValue];
}

@end
