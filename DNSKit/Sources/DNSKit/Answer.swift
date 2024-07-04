import Foundation

/// Describes a DNS answer
public struct Answer: Identifiable, Equatable, Comparable, CustomStringConvertible {
    /// Resource name
    public let name: String
    /// Record type
    public let recordType: RecordType
    /// Record class
    public let recordClass: RecordClass
    /// Maximum number of seconds this answer can be cached
    public let ttlSeconds: UInt32
    /// Length of record data
    public let dataLength: UInt16
    /// Record data
    public let data: RecordData
    /// Unique identifier for this answer, not from any DNS data - populated by DNSKit.
    public var id = UUID()

    fileprivate let recordData: Data

    internal init(name: String, recordType: RecordType, recordClass: RecordClass, ttlSeconds: UInt32, dataLength: UInt16, data: RecordData, recordData: Data) {
        self.name = name
        self.recordType = recordType
        self.recordClass = recordClass
        self.ttlSeconds = ttlSeconds
        self.dataLength = dataLength
        self.data = data
        self.recordData = recordData
    }

    public var description: String {
        return "\(self.name) \(self.ttlSeconds) \(self.recordClass.string()) \(self.recordType.string()) \(self.data.description)"
    }

    /// A hexedecimal representation of the record data for this answer
    public var hexValue: String {
        return self.recordData.hexEncodedString()
    }

    public static func == (lhs: Answer, rhs: Answer) -> Bool {
        return lhs.recordData == rhs.recordData
    }

    public static func < (lhs: Answer, rhs: Answer) -> Bool {
        let i = lhs.recordData.withUnsafeBytes { l in
            return rhs.recordData.withUnsafeBytes { r in
                return memcmp(l.baseAddress, r.baseAddress, lhs.recordData.count)
            }
        }
        return i < 0
    }

    internal func rawSignatureData(rrsigAnswer: Answer) throws -> Data {
        let labels = Name.splitName(self.name)

        guard let rrsig = rrsigAnswer.data as? RRSIGRecordData else {
            throw Utils.MakeError("Invalid RRSIG record data")
        }

        // wildcards
        var name: String
        if labels.count != rrsig.labelCount {
            name = "*.\(labels.suffix(from: labels.count-Int(rrsig.labelCount)).joined(separator: "."))"
        } else {
            name = self.name
        }

        // normalize the name
        name = name.lowercased()
        if name.suffix(1) != "." {
            name += "."
        }

        var data = Data()
        try data.append(Name.stringToName(name))
        data.append(self.recordType.rawValue.bigEndian)
        data.append(self.recordClass.rawValue.bigEndian)
        data.append(rrsig.ttlSeconds.bigEndian)
        data.append(self.dataLength.bigEndian)
        data.append(self.recordData)

        return data
    }
}
