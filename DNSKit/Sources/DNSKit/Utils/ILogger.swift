import Foundation

/// Log message levels
public enum LogLevel: Int {
    case Debug = 0
    case Information = 1
    case Warning = 2
    case Error = 3

    public func string() -> String {
        return String(describing: self)
    }
}

/// Describes a protocol for recieving log events from DNSKit
public protocol ILogger {
    /// Write a new line to the log
    /// - Parameters:
    ///   - level: The level of the message
    ///   - message: The log message
    func write(_ level: LogLevel, message: String)
}

/// The logging facility used by DNSKit. Defaults to an internal interface that just calls `print()`.
public var log: ILogger? = PrintLogger()

internal func printDebug(_ message: String) {
    log?.write(.Debug, message: message)
}

internal func printInformation(_ message: String) {
    log?.write(.Information, message: message)
}

internal func printWarning(_ message: String) {
    log?.write(.Warning, message: message)
}

internal func printError(_ message: String) {
    log?.write(.Error, message: message)
}

internal struct PrintLogger: ILogger {
    func write(_ level: LogLevel, message: String) {
        print("[\(level.string().uppercased())] [\(Date().ISO8601Format())] \(message)")
    }
}
