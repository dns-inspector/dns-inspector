import Foundation

/// Describes the shared record data type for a resource type where the value is always and only a DNS name.
///
/// > Note: You should always prefer to use the associated RecordData type that matches the value of the RecordType. Don't cast the record data to `BasicNameRecordData` directly.
public struct BasicNameRecordData: RecordData {
    public let name: String

    internal init(messageData: Data, startOffset: Int) throws {
        let (name, _) = try Name.readName(messageData, startOffset: startOffset)
        self.name = name
    }

    public var description: String {
        return self.name
    }
}
