import Foundation

/// Describes the record data for a DS record
public struct DSRecordData: RecordData {
    /// The key tag that signed this digest
    public let keyTag: UInt16
    /// The algorithm of the signature
    public let algorithm: DNSSECAlgorithm
    /// The digest type
    public let digestType: DNSSECDigest
    /// The digest data
    public let digest: Data

    internal init(recordData: Data) throws {
        let (keyTag, algorithmRaw, digestTypeRaw) = recordData.withUnsafeBytes { data in
            let keyTag = data.loadUnaligned(fromByteOffset: 0, as: UInt16.self).bigEndian
            let algorithmRaw = data.loadUnaligned(fromByteOffset: 2, as: UInt8.self)
            let digestTypeRaw = data.loadUnaligned(fromByteOffset: 3, as: UInt8.self)
            return (keyTag, algorithmRaw, digestTypeRaw)
        }

        guard let algorithm = DNSSECAlgorithm(rawValue: algorithmRaw) else {
            throw Utils.MakeError("Unknown or unsupported DNSSEC algorithm")
        }

        guard let digestType = DNSSECDigest(rawValue: digestTypeRaw) else {
            throw Utils.MakeError("Unknown or unsupported DNSSEC digest type")
        }

        let digest = recordData.suffix(from: 4)

        self.keyTag = keyTag
        self.algorithm = algorithm
        self.digestType = digestType
        self.digest = digest
    }

    public var description: String {
        return "\(self.keyTag) \(self.algorithm.rawValue) \(self.digestType.rawValue) \(self.digest.hexEncodedString())"
    }
}
