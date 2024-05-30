#import "DNSSOARecordData.h"
#import "DNSName.h"
#import "NSData+ByteAtIndex.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSSOARecordData()

@property (nonatomic, strong, nonnull, readwrite) NSString * mname;
@property (nonatomic, strong, nonnull, readwrite) NSString * rname;

@end

@implementation DNSSOARecordData

+ (DNSSOARecordData *) readFromDNSMessage:(NSData *)data startingAt:(int)index error:(NSError **)error {
    int rnameIndex = 0;
    int serialIndex = 0;

    NSError * nameError;
    NSString * mname = [DNSName readDNSName:data startIndex:index dataIndex:&rnameIndex error:&nameError];
    if (nameError != nil) {
        *error = nameError;
        return nil;
    }

    NSString * rname = [DNSName readDNSName:data startIndex:rnameIndex dataIndex:&serialIndex error:&nameError];
    if (nameError != nil) {
        *error = nameError;
        return nil;
    }

    uint32_t serial = ntohl(*(uint32_t *)[data subdataWithRange:NSMakeRange(serialIndex, 4)].bytes);
    int32_t refresh = ntohl(*(int32_t *)[data subdataWithRange:NSMakeRange(serialIndex+4, 4)].bytes);
    int32_t retry = ntohl(*(int32_t *)[data subdataWithRange:NSMakeRange(serialIndex+8, 4)].bytes);
    int32_t expire = ntohl(*(int32_t *)[data subdataWithRange:NSMakeRange(serialIndex+12, 4)].bytes);
    uint32_t minimum = ntohl(*(uint32_t *)[data subdataWithRange:NSMakeRange(serialIndex+16, 4)].bytes);

    DNSSOARecordData * record = [DNSSOARecordData new];
    record.mname = mname;
    record.rname = rname;
    record.serial = serial;
    record.refresh = refresh;
    record.retry = retry;
    record.expire = expire;
    record.minimum = minimum;

    return record;
}

@end

NS_ASSUME_NONNULL_END
