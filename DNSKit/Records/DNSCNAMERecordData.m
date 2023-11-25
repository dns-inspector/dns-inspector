#import "DNSCNAMERecordData.h"
#import "DNSRecordData+Private.h"
#import "DNSCNAMERecordData+Private.h"

@interface DNSCNAMERecordData ()
@property (strong, nonatomic, nullable, readwrite) NSString * name;
@end

@implementation DNSCNAMERecordData

- (id) initWithName:(NSString *)name {
    self = [super init];
    self.name = name;
    return self;
}

@end
