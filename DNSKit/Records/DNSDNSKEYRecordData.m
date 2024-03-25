#import "DNSDNSKEYRecordData.h"
#import "DNSRecordData+Private.h"
#import "NSData+ByteAtIndex.h"

@interface DNSDNSKEYRecordData ()

@property (nonatomic, readwrite) bool zoneKey;
@property (nonatomic, readwrite) bool revoked;
@property (nonatomic, readwrite) bool zoneSigningKey;
@property (nonatomic, readwrite) NSUInteger protocol;
@property (nonatomic, readwrite) DNSSECAlgorithm algoritm;
@property (strong, nonatomic, nonnull, readwrite) NSData * publicKey;

@end

@implementation DNSDNSKEYRecordData

- (id) initWithRecordValue:(NSData *)value {
    self = [super initWithRecordValue:value];

    uint8_t flag1 = [self.recordValue byteAtIndex:0];
    uint8_t flag2 = [self.recordValue byteAtIndex:1];

    bool zoneKey = (flag1 & 0x01) > 0;
    bool revoked = (flag2 & 0x10) > 0;
    bool zsk = (flag2 & 0x01) > 0;

    uint8_t protocol = (uint8_t)[self.recordValue byteAtIndex:2];
    uint8_t algorithm = (uint8_t)[self.recordValue byteAtIndex:3];
    NSData * publicKey = [self.recordValue subdataWithRange:NSMakeRange(4, self.recordValue.length-4)];

    self.zoneKey = zoneKey;
    self.revoked = revoked;
    self.zoneSigningKey = zsk;
    self.protocol = protocol;
    self.algoritm = (DNSSECAlgorithm)algorithm;
    self.publicKey = publicKey;

    return self;
}

@end
