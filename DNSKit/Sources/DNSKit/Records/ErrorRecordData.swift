import Foundation

/// Describes a placeholder record data type for when DNSKit could not deserlize the data
public struct ErrorRecordData: RecordData {
    /// The error that occured while deserlizing the record data
    public let error: Error

    internal init(error: Error) {
        self.error = error
    }

    public var description: String {
        return "Invalid record: \(self.error)"
    }
}
