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

@end
