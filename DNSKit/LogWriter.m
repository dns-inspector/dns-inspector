#import "LogWriter.h"
#include <UIKit/UIKit.h>
#include <mach/mach.h>
#include <mach/mach_time.h>

@interface LogWriter ()

@property (strong, nonatomic) NSObject * lock;
@property (strong, nonatomic) NSFileHandle * handle;

@end

static id _instance;

@implementation LogWriter

+ (LogWriter *) sharedInstance {
    if (!_instance) {
        _instance = [LogWriter new];
    }
    return _instance;
}

- (id) init {
    if (_instance == nil) {
        _instance = [[LogWriter alloc] initWithLogFile:@"DNSKit.log"];
        self.lock = [NSObject new];
    }
    return _instance;
}

- (id) initWithLogFile:(NSString *)file {
    self = [super init];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    self.file = [documentsDirectory stringByAppendingPathComponent:file];
    [self open];
#if DEBUG
    self.level = LogWriterLevelDebug;
#else
    self.level = LogWriterLevelWarning;
#endif
    return self;
}

- (void) open {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];

    if (![[NSFileManager defaultManager] fileExistsAtPath:self.file]) {
        [[NSFileManager defaultManager] createFileAtPath:self.file contents:nil attributes:nil];
    }

    self.handle = [NSFileHandle fileHandleForWritingAtPath:self.file];
    [self.handle seekToEndOfFile];
}

- (void) appWillTerminate:(NSNotification *)n {
    [self close];
}

- (void) close {
    [self.handle closeFile];
}

- (void) truncateLogs {
    @synchronized (self.lock) {
        [self.handle closeFile];
        [[NSFileManager defaultManager] removeItemAtPath:self.file error:nil];
        [self open];
    }
}

- (NSString *) stringForLevel:(LogWriterLevel)level {
    switch (level) {
        case LogWriterLevelDebug:
            return @"DEBUG";
        case LogWriterLevelInfo:
            return @"INFO ";
        case LogWriterLevelError:
            return @"ERROR";
        case LogWriterLevelWarning:
            return @"WARN ";
    }
}

- (void) write:(NSString *)string forLevel:(LogWriterLevel)level {
    NSString * thread = [NSString stringWithFormat:@"%p", NSThread.currentThread];
    @synchronized (self.lock) {
        NSString * writeString = [NSString stringWithFormat:@"[%@][%ld][%@] %@",
                                  [self stringForLevel:level], time(0), thread, string];
        [self.handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
        printf("%s", [writeString UTF8String]);
    }
}

- (void) writeLine:(NSString *)string forLevel:(LogWriterLevel)level {
    if (self.level <= level) {
        [self write:[NSString stringWithFormat:@"%@\n", string] forLevel:level];
    }
}

- (void) writeDebug:(NSString *)message {
    [self writeLine:message forLevel:LogWriterLevelDebug];
}

- (void) writeInfo:(NSString *)message {
    [self writeLine:message forLevel:LogWriterLevelInfo];
}

- (void) writeWarn:(NSString *)message {
    [self writeLine:message forLevel:LogWriterLevelWarning];
}

- (void) writeError:(NSString *)message {
    [self writeLine:message forLevel:LogWriterLevelError];
}

- (void) setLevel:(LogWriterLevel)level {
#ifndef DEBUG
    _level = level;
    [self writeDebug:[NSString stringWithFormat:@"Setting log level to: %@ (%lu)", [self stringForLevel:level], (unsigned long)level]];
#endif
}

@end
