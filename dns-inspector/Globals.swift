import Foundation

let presetServerChangedNotification = Notification.Name(rawValue: "preset.server.changed")

/// Create an error object with the given localized description.
/// - Parameter description: The localized description value
/// - Returns: An error object. The error code will be -1.
func MakeError(_ description: String) -> Error {
    return MakeError(description, code: -1)
}

/// Create an error object with the given localized description and code.
/// - Parameters:
///   - description: The localized description value
///   - code: The error code.
/// - Returns: An error object.
func MakeError(_ description: String, code: Int) -> Error {
    return NSError(domain: "io.ecn.dns-inspector", code: -1, userInfo: [NSLocalizedDescriptionKey: description])
}
