#import "DNSNSRecordData.h"
#import "DNSRecordData+Private.h"
#import "DNSNSRecordData+Private.h"

@interface DNSNSRecordData ()
@property (strong, nonatomic, nullable, readwrite) NSString * name;
@end

@implementation DNSNSRecordData

- (id) initWithName:(NSString *)name {
    self = [super init];
    self.name = name;
    return self;
}

- (NSString *) stringValue {
    return self.name;
}

@end
