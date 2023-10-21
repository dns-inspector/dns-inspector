#import "DNSName.h"
#import "NSData+ByteAtIndex.h"

@implementation DNSName

+ (NSData *) stringToDNSName:(NSString *)name error:(NSError **)error {
    NSMutableData * request = [NSMutableData new];
    char len;

    NSArray<NSString *> * labels = [name componentsSeparatedByString:@"."];
    for (NSString * label in labels) {
        if (label.length > 63) {
            *error = MAKE_ERROR(500, @"Host name is too long");
            return nil;
        }

        len = (short)label.length;
        [request appendBytes:&len length:1];
        if (label.length > 0) {
            [request appendData:[label dataUsingEncoding:NSASCIIStringEncoding]];
        }
    }

    len = 0;
    [request appendBytes:&len length:1];
    return request;
}

+ (NSString *) readDNSName:(NSData *)data startIndex:(int)startIdx dataIndex:(int *)dataIndex error:(NSError **)error {
    NSMutableString * name = [[NSMutableString alloc] initWithCapacity:255];
    short offset = startIdx;

    // DNS compression can apply to the entire name or individual lables, so check for pointers at each label
    while (true) {
        PDebug(@"Read byte %i", offset);
        short ptrFlag = [data byteAtIndex:offset];
        if (ptrFlag == 0) {
            break;
        }

        if (ptrFlag & (1 << 7)) {
            PDebug(@"Byte is pointer");
            if (dataIndex != NULL) {
                *dataIndex = startIdx+2;
            }

            short nextOffset = offset;
            int depth = 0;
            // Continue to follow pointers until we get to a length
            while (ptrFlag & (1 << 7)) {
                PDebug(@"Byte is pointer");
                // DNS pointers can refer to another pointer, limit to a recursion depth of 10
                if (depth > 10) {
                    PError(@"Maximum pointer depth exceeded");
                    *error = MAKE_ERROR(1, @"Bad response");
                    return nil;
                }

                PDebug(@"Read byte %i", offset+1);
                nextOffset = [data byteAtIndex:offset+1];
                if (nextOffset > data.length-1) {
                    PError(@"Offset %i exceeds data length %lu", nextOffset, (unsigned long)data.length);
                    *error = MAKE_ERROR(1, @"Bad response");
                    return nil;
                }

                PDebug(@"Pointer destination is offset %i", nextOffset);
                PDebug(@"Read byte %i", nextOffset);
                ptrFlag = [data byteAtIndex:nextOffset];
                depth++;
            }
            PDebug(@"Byte is length");
            offset = nextOffset;
        }

        if (offset > data.length) {
            PError(@"Offset %i exceeds data length %lu", offset, (unsigned long)data.length);
            *error = MAKE_ERROR(1, @"Bad response");
            return nil;
        }

        PDebug(@"Read byte %i", offset);
        short len = [data byteAtIndex:offset];
        offset++;

        if (offset+len > data.length-1) {
            PError(@"Bad length %i or offset %i", len, offset);
            *error = MAKE_ERROR(1, @"Bad response");
            return nil;
        }

        NSString * label = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(offset, len)] encoding:NSASCIIStringEncoding];
        PDebug(@"Label length %i at offset %i: %@", len, offset, label);
        offset += len;

        // Reject labels that contain '.', as these are implied as separators to labels
        if ([label containsString:@"."]) {
            PDebug(@"Invalid characters in label %@", label);
            *error = MAKE_ERROR(1, @"Bad response");
            return nil;
        }

        [name appendFormat:@"%@.", label];
        PDebug(@"name %@", name);
    }
    if (dataIndex != NULL && *dataIndex == 0) {
        *dataIndex = startIdx + (int)name.length + 1; // +1 for the terminating 0 length
    }

    return name;
}

@end
