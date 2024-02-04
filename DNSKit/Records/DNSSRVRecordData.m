#import "DNSSRVRecordData.h"
#import "DNSRecordData+Private.h"

@interface DNSSRVRecordData ()
@property (strong, nonatomic, nullable, readwrite) NSNumber * priority;
@property (strong, nonatomic, nullable, readwrite) NSNumber * weight;
@property (strong, nonatomic, nullable, readwrite) NSNumber * port;
@property (strong, nonatomic, nullable, readwrite) NSString * name;
@end

@implementation DNSSRVRecordData

- (id) initWithPriority:(NSNumber *)priority weight:(NSNumber *)weight port:(NSNumber *)port name:(NSString *)name {
    self = [super init];
    self.priority = priority;
    self.weight = weight;
    self.port = port;
    self.name = name;
    return self;
}

- (NSString *) stringValue {
    return [NSString stringWithFormat:@"Priority: %i, Weight: %i, Port: %i, Name: %@", self.priority.intValue, self.weight.intValue, self.port.intValue, self.name];
}

@end
