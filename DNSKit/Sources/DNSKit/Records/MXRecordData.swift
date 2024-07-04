import Foundation

/// Describes the record data for a MX record
public struct MXRecordData: RecordData {
    /// The record priority
    public let priority: UInt16
    /// The mail server name
    public let name: String

    internal init(messageData: Data, startOffset: Int) throws {
        let priority = messageData.withUnsafeBytes { data in
            return data.loadUnaligned(fromByteOffset: startOffset, as: UInt16.self).bigEndian
        }
        let (name, _) = try Name.readName(messageData, startOffset: startOffset+2)

        self.priority = priority
        self.name = name
    }

    public var description: String {
        return "\(self.priority) \(self.name)"
    }
}
