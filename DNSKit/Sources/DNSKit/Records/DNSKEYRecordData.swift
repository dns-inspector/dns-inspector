import Foundation
import CommonCrypto

/// Describes the record data for an DNSKEY record
public struct DNSKEYRecordData: RecordData {
    /// If this key is the zone key
    public let zoneKey: Bool
    /// If this key is revoked
    public let revoked: Bool
    /// If this key is a key signing key
    public let keySigningKey: Bool
    /// The protocol for this key. This should always be 3.
    public let keyProtocol: UInt8
    /// The key algorithm
    public let algorithm: DNSSECAlgorithm
    /// The public key data
    public let publicKey: Data
    /// The key tag for this public key
    public let keyTag: UInt32

    fileprivate let recordData: Data

    internal init(recordData: Data) throws {
        let (zoneKey, revoked, ksk, keyProtocol, rawAlgorithm) = recordData.withUnsafeBytes { data in
            let flags = data.load(fromByteOffset: 0, as: UInt16.self).bigEndian
            let keyProtocol = data.load(fromByteOffset: 2, as: UInt8.self)
            let algorithm = data.load(fromByteOffset: 3, as: UInt8.self)

            let zoneKey = flags & 0x0100 > 0
            let revoked = flags & 0x0010 > 0
            let ksk = flags & 0x0001 > 0

            return (zoneKey, revoked, ksk, keyProtocol, algorithm)
        }

        let publicKey = recordData.suffix(from: 4)

        let keyTag = recordData.withUnsafeBytes { data in
            var keytag = UInt32(0)
            for i in 0...recordData.count-1 {
                let value = UInt32(data.loadUnaligned(fromByteOffset: i, as: UInt8.self))
                keytag += (i & 1) != 0 ? value : value << 8
            }

            keytag += (keytag >> 16) & 0xFFFF
            return keytag & 0xFFFF
        }

        guard let algorithm = DNSSECAlgorithm(rawValue: rawAlgorithm) else {
            throw Utils.MakeError("Unknown or unsupported DNSSEC algorithm")
        }

        self.zoneKey = zoneKey
        self.revoked = revoked
        self.keySigningKey = ksk
        self.keyProtocol = keyProtocol
        self.algorithm = algorithm
        self.publicKey = publicKey
        self.keyTag = keyTag
        self.recordData = recordData
    }

    /// Parse the public key for use
    /// - Returns: A SecKey of the public key
    /// - Throws: On invalid or unsupported public key
    public func parsePublicKey() throws -> SecKey {
        let keyAttributes: [CFString: CFString]
        let keyToParse: Data

        switch self.algorithm {
        case .RSA_SHA256, .RSA_SHA512:
            keyAttributes = [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: kSecAttrKeyClassPublic
            ]

            if self.publicKey.count < 66 {
                throw Utils.MakeError("Invalid size of RSA key")
            }

            let keyBytes: [UInt8] = Array(self.publicKey)

            let exponentLength: UInt16
            let exponentOffset: Int

            // DNSKEY formats RSA keys as Exponent Length + Exponent + Modulus
            // Exponent length is either 1 or 3 bytes. If the first byte is 0, then the next two bytes are the length.
            if keyBytes[0] == 0 {
                exponentLength = UInt16((keyBytes[1] << 8) | keyBytes[2])
                exponentOffset = 3
            } else {
                exponentLength = UInt16(keyBytes[0])
                exponentOffset = 1
            }

            if exponentLength > 4 || exponentLength == 0 {
                throw Utils.MakeError("Invalid RSA key")
            }

            let modulusOffset = exponentOffset+Int(exponentLength)
            var exponentBytes = Array(repeating: UInt8(0x0), count: 4)
            for i in 0...3 {
                if i+1 > exponentLength {
                    exponentBytes[i] = 0x0
                } else {
                    exponentBytes[i] = keyBytes[i+1]
                }
            }
            var exponent: UInt32 = 0
            _ = withUnsafeMutableBytes(of: &exponent) {
                exponentBytes.copyBytes(to: $0)
            }

            let modulus = Data(keyBytes[modulusOffset...])

            keyToParse = ASN1.pkcs1RSAPubkey(exponent: exponent, exponentLength: exponentLength, modulus: modulus)
        case .ECDSAP256_SHA256, .ECDSAP384_SHA384:
            keyAttributes = [
                kSecAttrKeyType: kSecAttrKeyTypeEC,
                kSecAttrKeyClass: kSecAttrKeyClassPublic
            ]

            // Apple needs EC public keys to have the uncompressed flag 0x04
            var pkey = Data([0x04])
            pkey.append(self.publicKey)

            keyToParse = pkey
        default:
            throw Utils.MakeError("Unsupported key algorithm")
        }

        var keyError: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(keyToParse as CFData, keyAttributes as CFDictionary, &keyError) else {
            throw Utils.MakeError("Invalid public key")
        }

        return key
    }

    internal func hashWithOwnerName(_ ownerName: String, digest: DNSSECDigest) throws -> Data {
        var hashedData = Data()
        try hashedData.append(Name.stringToName(ownerName))
        hashedData.append(self.recordData)

        let digestLength: Int
        let digestFunc: (_ data: UnsafeRawPointer?, _ len: CC_LONG, _ md: UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<UInt8>?

        switch digest {
        case .SHA1:
            digestLength = Int(CC_SHA1_DIGEST_LENGTH)
            digestFunc = CC_SHA1
        case .SHA256:
            digestLength = Int(CC_SHA256_DIGEST_LENGTH)
            digestFunc = CC_SHA256
        case .SHA384:
            digestLength = Int(CC_SHA384_DIGEST_LENGTH)
            digestFunc = CC_SHA384
        }

        var buffer = ContiguousArray<UInt8>(repeating: 0, count: digestLength)
        return hashedData.withUnsafeBytes { hash in
            return buffer.withUnsafeMutableBufferPointer { buf in
                guard let result = digestFunc(hash.baseAddress!, UInt32(hashedData.count) as CC_LONG, buf.baseAddress!) else {
                    fatalError()
                }
                return Data(bytes: result, count: digestLength)
            }
        }
    }

    public var description: String {
        var flags = UInt16(0)
        if zoneKey {
            flags |= 0x0100
        }
        if revoked {
            flags |= 0x0010
        }
        if keySigningKey {
            flags |= 0x0001
        }

        return "\(flags) \(self.keyProtocol) \(self.algorithm.rawValue) \(self.publicKey.base64EncodedString())"
    }
}
