import Foundation

internal class Utils {
    internal static func MakeError(_ description: String) -> Error {
        return MakeError(description, code: -1)
    }

    internal static func MakeError(_ description: String, code: Int) -> Error {
        return NSError(domain: "io.ecn.dnskit", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
