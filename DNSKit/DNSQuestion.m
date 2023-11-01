#import "DNSQuestion.h"

@implementation DNSQuestion

- (DNSQuestion *) initWithName:(NSString *)name recordType:(DNSRecordType)recordType recordClass:(DNSRecordClass)recordClass {
    self = [super init];
    self.name = name;
    self.recordType = recordType;
    self.recordClass = recordClass;
    return self;
}

@end
