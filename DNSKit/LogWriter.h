#import <DNSKit/DNSKit.h>

/// The certificate kit logging class
@interface LogWriter : NSObject

/**
 Logging levels for the certificate kit log

 - LogWriterLevelDebug: Debug logs will include all information sent to the log instance,
                        including domain names. Use with caution.
 - LogWriterLevelInfo: Informational logs for irregular, but not dangerous events.
 - LogWriterLevelWarning: Warning logs for dangerous, but not fatal events.
 - LogWriterLevelError: Error events for when things really go sideways.
 */
typedef NS_ENUM(NSUInteger, LogWriterLevel) {
    LogWriterLevelDebug = 0,
    LogWriterLevelInfo,
    LogWriterLevelWarning,
    LogWriterLevelError,
};

/// The shared instance of the LogWriter class
+ (LogWriter * _Nonnull) sharedInstance;

/// The current logging level
@property (nonatomic) LogWriterLevel level;
/// The filepath of the log file
@property (strong, nonatomic, nonnull) NSString * file;

/// Close this instance. Should only be called when the application is crashing.
- (void) close;

/// Purge all log files
- (void) truncateLogs;

/// Write a DEBUG level message
/// @param message The message to write
- (void) writeDebug:(NSString * _Nonnull)message;

/// Write a DEBUG level message
/// @param message The message to write
/// @param file The source file
/// @param line The source file line
- (void) writeDebug:(NSString * _Nonnull)message file:(char * _Nonnull)file line:(int)line;

/// Write an INFO level message
/// @param message The message to write
- (void) writeInfo:(NSString * _Nonnull)message;

/// Write a INFO level message
/// @param message The message to write
/// @param file The source file
/// @param line The source file line
- (void) writeInfo:(NSString * _Nonnull)message file:(char * _Nonnull)file line:(int)line;

/// Write a WARN level message
/// @param message The message to write
- (void) writeWarn:(NSString * _Nonnull)message;

/// Write a WARN level message
/// @param message The message to write
/// @param file The source file
/// @param line The source file line
- (void) writeWarn:(NSString * _Nonnull)message file:(char * _Nonnull)file line:(int)line;

/// Write an ERROR level message
/// @param message The message to write
- (void) writeError:(NSString * _Nonnull)message;

/// Write a ERROR level message
/// @param message The message to write
/// @param file The source file
/// @param line The source file line
- (void) writeError:(NSString * _Nonnull)message file:(char * _Nonnull)file line:(int)line;

@end
