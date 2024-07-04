import Foundation

private enum ASN1ObjectType: UInt8 {
    case Integer = 0x02
    case Sequence = 0x30
}

internal struct ASN1 {
    fileprivate static let twoByteLengthFlag: UInt8 = 0x82

    /// Generate a PKCS.1 RSA public key
    /// - Parameters:
    ///   - exponent: The exponent
    ///   - exponentLength: The length of the exponent
    ///   - modulus: The modulus
    /// - Returns: a PKCS.1 RSA public key
    ///
    /// DNSSEC returns RSA keys as 1 or 3 bytes for the length of the exponent, then the remainder of the bytes for the
    /// modulus. Apple expects RSA keys to be a ASN.1 sequence of the modulus then the exponent.
    ///
    /// For the exponent length, if the first byte is 0 then the next two bytes are the length of the exponnet. Howevever,
    /// DNSKit does not support exponents greater than 4 bytes - which will always fit within 1 byte for length.
    internal static func pkcs1RSAPubkey(exponent: UInt32, exponentLength: UInt16, modulus: Data) -> Data {
        // If the first bit of the modulous is 1, its a negative number. ASN.1 pads negative numbers with an extra 0 byte
        let firstByte = modulus.withUnsafeBytes { mod in
            return mod[0...0].loadUnaligned(as: UInt8.self)
        }

        var paddedModulus = Data()
        if firstByte & 0x80 != 0 {
            paddedModulus.appendZeroByte()
            paddedModulus.append(modulus)
        } else {
            paddedModulus.append(modulus)
        }

        var publicKey = ASN1.objectHeader(.Sequence, length: ASN1.twoByteLengthFlag)
        let sequenceLength: UInt16 = (4 + UInt16(paddedModulus.count) + 2 + UInt16(exponentLength))
        let sequenceLengthBig = sequenceLength.bigEndian
        publicKey.append(sequenceLengthBig)

        // Modulus
        publicKey.append(ASN1.objectHeader(.Integer, length: ASN1.twoByteLengthFlag))
        publicKey.append(UInt16(paddedModulus.count).bigEndian)
        publicKey.append(paddedModulus)

        // Exponent
        publicKey.append(ASN1.objectHeader(.Integer, length: UInt8(exponentLength)))
        withUnsafePointer(to: exponent) {
            publicKey.append(Data(bytes: $0, count: Int(exponentLength)))
        }

        return publicKey
    }

    /// Transform a DNSSEC signature into a PKCS.1 signature
    /// - Parameters:
    ///   - signature: The signature data
    ///   - algorithm: The algorithm of the signature
    /// - Returns: A PKCS.1 signature
    internal static func pkcs1Signature(_ signature: Data, algorithm: DNSSECAlgorithm) -> Data {
        switch algorithm {
        case .RSA_SHA1, .RSA_SHA256, .RSA_SHA512:
            // No transformation needed
            return signature
        case .ECDSAP256_SHA256, .ECDSAP384_SHA384:
            // DNSSEC returns the bare R and S coords concationated together
            // but Apple expects it to be in a ASN.1 sequence.
            let rData = signature.prefix(signature.count/2)
            let sData = signature.suffix(signature.count/2)

            let r = ASN1.asn1Integer(rData)
            let s = ASN1.asn1Integer(sData)

            var signature = Data()
            let sequenceLength = UInt8(r.count + s.count)
            let header = ASN1.objectHeader(.Sequence, length: sequenceLength)

            signature.append(header)
            signature.append(r)
            signature.append(s)

            return signature
        }
    }

    /// Return an ASN.1 integer object
    /// - Parameter number: The number data
    /// - Returns: An ASN.1 integer object
    internal static func asn1Integer(_ number: Data) -> Data {
        let needsPadding = number.withUnsafeBytes { n in
            return n.load(as: UInt8.self) & 0x80 != 0
        }

        var entry = Data()
        let entryLength = UInt8(number.count + (needsPadding ? 1 : 0))
        let header = ASN1.objectHeader(.Integer, length: entryLength)

        entry.append(header)
        if needsPadding {
            entry.appendZeroByte()
        }
        entry.append(number)
        return entry
    }

    fileprivate static func objectHeader(_ objectType: ASN1ObjectType, length: UInt8) -> Data {
        return Data([objectType.rawValue, length])
    }
}
