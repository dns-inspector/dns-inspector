#import "DNSRecordData.h"
#import "DNSRecordData+Private.h"
#import "NSData+HexString.h"

@interface DNSRecordData ()

@property (strong, nonatomic, nonnull, readwrite) NSData * recordValue;

@end

@implementation DNSRecordData

- (id) initWithRecordValue:(NSData * _Nonnull)value {
    self = [super init];
    self.recordValue = value;
    return self;
}

- (NSString *) hexValue {
    return [self.recordValue hexString];
}

@end
