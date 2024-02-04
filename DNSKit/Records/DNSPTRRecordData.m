#import "DNSPTRRecordData.h"
#import "DNSRecordData+Private.h"
#import "DNSPTRRecordData+Private.h"

@interface DNSPTRRecordData ()
@property (strong, nonatomic, nullable, readwrite) NSString * name;
@end

@implementation DNSPTRRecordData

- (id) initWithName:(NSString *)name {
    self = [super init];
    self.name = name;
    return self;
}

- (NSString *) stringValue {
    return self.name;
}

@end
