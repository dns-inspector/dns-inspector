import Foundation

internal extension NSRegularExpression {
    convenience init(_ pattern: String, options: Options = Options()) {
        do {
            try self.init(pattern: pattern, options: options)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
}
