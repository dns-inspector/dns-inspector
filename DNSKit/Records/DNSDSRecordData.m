#import "DNSDSRecordData.h"
#import "DNSRecordData+Private.h"
#import "NSData+ByteAtIndex.h"
#import "NSData+HexString.h"

@interface DNSDSRecordData ()

@property (nonatomic, readwrite) NSUInteger keyTag;
@property (nonatomic, readwrite) DNSSECAlgorithm algorithmType;
@property (nonatomic, readwrite) DNSSECDigest digestType;
@property (strong, nonatomic, nonnull, readwrite) NSData * digest;

@end

@implementation DNSDSRecordData

- (id) initWithRecordValue:(NSData *)value {
    self = [super initWithRecordValue:value];

    uint16_t keyTag = ntohs(*(uint16_t *)[self.recordValue subdataWithRange:NSMakeRange(0, 2)].bytes);
    DNSSECAlgorithm algorithmType = (DNSSECAlgorithm)[self.recordValue byteAtIndex:2];
    DNSSECDigest digestType = (DNSSECDigest)[self.recordValue byteAtIndex:3];

    NSData * digest = [self.recordValue subdataWithRange:NSMakeRange(4, self.recordValue.length-4)];

    self.keyTag = keyTag;
    self.algorithmType = algorithmType;
    self.digestType = digestType;
    self.digest = digest;

    return self;
}

- (NSString *) stringValue {
    return [NSString stringWithFormat:@"%i %i %i %@", (int)self.keyTag, (int)self.algorithmType, (int)self.digestType, [self.digest hexString]];
}

@end
