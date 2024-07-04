import Foundation

/// Describes a DNS question
public struct Question {
    /// The resource's name
    public let name: String
    /// The resource's record type
    public let recordType: RecordType
    /// The resource's record class
    public let recordClass: RecordClass

    internal func data() throws -> Data {
        var data = Data()
        let name = try Name.stringToName(self.name)
        data.append(name)

        let rtype = UInt16(self.recordType.rawValue).bigEndian
        let rclass = UInt16(self.recordClass.rawValue).bigEndian

        withUnsafePointer(to: rtype) { rt in
            data.append(Data(bytes: rt, count: 2))
        }
        withUnsafePointer(to: rclass) { rc in
            data.append(Data(bytes: rc, count: 2))
        }

        return data
    }
}
