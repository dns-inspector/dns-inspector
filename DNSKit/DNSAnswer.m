#import "DNSAnswer.h"
#import "NSData+HexString.h"

@implementation DNSAnswer

- (DNSAnswer *) initWithName:(NSString *)name recordType:(DNSRecordType)recordType recordClass:(DNSRecordClass)recordClass ttlSeconds:(NSUInteger)ttlSeconds data:(NSData *)data {
    self = [super self];
    self.name = name;
    self.recordType = recordType;
    self.recordClass = recordClass;
    self.ttlSeconds = ttlSeconds;
    self.data = data;
    return self;
}

- (NSString *) dataDescription {
    switch (self.recordType) {
        case DNSRecordTypeA:
        case DNSRecordTypeAAAA:
        case DNSRecordTypeCNAME: {
            return [[NSString alloc] initWithData:self.data encoding:NSASCIIStringEncoding];
            break;
        case DNSRecordTypeTXT:
            return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
            break;
        default:
            return [self.data hexString];
        }
    }

    return @"";
}

@end
