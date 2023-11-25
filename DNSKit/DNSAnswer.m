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

@end
