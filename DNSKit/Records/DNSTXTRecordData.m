#import "DNSTXTRecordData.h"
#import "NSData+ByteAtIndex.h"
#import "DNSRecordData+Private.h"

@implementation DNSTXTRecordData

- (NSString *) text {
    // TXT RDATA format is a collection of one or more strings, which are: length (uint8) + data
    // No encoding is defined, so we'll assumt UTF8 and throw caution to the wind.
    NSMutableString * text = [NSMutableString new];
    bool moreToRead = true;
    int offset = 0;
    while (moreToRead) {
        uint8_t length = [self.recordValue byteAtIndex:offset];
        if (length <= 0 || offset+length > self.recordValue.length) {
            return text;
        }
        offset += 1;
        [text appendString:[[NSString alloc] initWithData:[self.recordValue subdataWithRange:NSMakeRange(offset, length)] encoding:NSUTF8StringEncoding]];
        offset += length;

        if (self.recordValue.length - 1 <= offset) {
            moreToRead = false;
        }
    }

    return text;
}

- (NSString *) stringValue {
    return self.text;
}

@end
