#import "DNSMXRecordData.h"
#import "DNSRecordData+Private.h"

@interface DNSMXRecordData ()
@property (strong, nonatomic, nullable, readwrite) NSNumber * priority;
@property (strong, nonatomic, nullable, readwrite) NSString * name;
@end

@implementation DNSMXRecordData

- (id) initWithPriority:(NSNumber *)priority name:(NSString *)name {
    self = [super init];
    self.priority = priority;
    self.name = name;
    return self;
}

@end
