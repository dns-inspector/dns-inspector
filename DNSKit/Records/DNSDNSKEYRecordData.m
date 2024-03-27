#import "DNSDNSKEYRecordData.h"
#import "DNSRecordData+Private.h"
#import "NSData+ByteAtIndex.h"

@interface DNSDNSKEYRecordData ()

@property (nonatomic, readwrite) bool zoneKey;
@property (nonatomic, readwrite) bool revoked;
@property (nonatomic, readwrite) bool keySigningKey;
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
    bool ksk = (flag2 & 0x01) > 0;

    uint8_t protocol = (uint8_t)[self.recordValue byteAtIndex:2];
    uint8_t algorithm = (uint8_t)[self.recordValue byteAtIndex:3];
    NSData * publicKey = [self.recordValue subdataWithRange:NSMakeRange(4, self.recordValue.length-4)];

    self.zoneKey = zoneKey;
    self.revoked = revoked;
    self.keySigningKey = ksk;
    self.protocol = protocol;
    self.algoritm = (DNSSECAlgorithm)algorithm;
    self.publicKey = publicKey;

    return self;
}

- (NSUInteger) keyTag {
    uint8_t * value = (uint8_t *)self.recordValue.bytes;

    unsigned long keytag = 0;

    for (int i = 0; i < self.recordValue.length; i++) {
        keytag += (i & 1) ? value[i] : value[i] << 8;
    }

    keytag += (keytag >> 16) & 0xFFFF;
    return keytag & 0xFFFF;
}

@end
