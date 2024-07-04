import Foundation

/// DNS record types
public enum RecordType: UInt16, Codable, CaseIterable {
    case A = 1
    case NS = 2
    case CNAME = 5
    case SOA = 6
    case AAAA = 28
    case SRV = 33
    case TXT = 16
    case MX = 15
    case PTR = 12
    case DS = 43
    case RRSIG = 46
    case DNSKEY = 48

    public func string() -> String {
        return String(describing: self)
    }
}

/// DNS record classes
public enum RecordClass: UInt16, Codable, CaseIterable {
    case IN = 1
    case CS = 2
    case CH = 3
    case HS = 4

    public  func string() -> String {
        return String(describing: self)
    }
}

/// Transport options
public enum TransportType: String, Codable, CaseIterable {
    case DNS = "dns"
    case TLS = "tls"
    case HTTPS = "https"

    public func string() -> String {
        return String(describing: self)
    }
}

/// DNS response codes
public enum ResponseCode: Int, Codable, CaseIterable {
    case NOERROR = 0
    case FORMERR = 1
    case SERVFAIL = 2
    case NXDOMAIN = 3
    case NOTIMP = 4
    case REFUSED = 5
    case YXDOMAIN = 6
    case XRRSET = 7
    case NOTAUTH = 8
    case NOTZONE = 9

    public func string() -> String {
        return String(describing: self)
    }
}

/// DNS operation codes
public enum OperationCode: Int, Codable, CaseIterable {
    case Query = 0
    case IQuery = 1
    case Status = 2
    case Notify = 4
    case Update = 5

    public func string() -> String {
        return String(describing: self)
    }
}

/// DNSSEC algorithms
public enum DNSSECAlgorithm: UInt8, Codable {
    case ECDSAP384_SHA384 = 14
    case ECDSAP256_SHA256 = 13
    case RSA_SHA512 = 10
    case RSA_SHA256 = 8
    case RSA_SHA1 = 5

    public func string() -> String {
        return String(describing: self)
    }
}

/// DNSSEC digest types
public enum DNSSECDigest: UInt8, Codable {
    case SHA1 = 1
    case SHA256 = 2
    case SHA384 = 4

    public func string() -> String {
        return String(describing: self)
    }
}

/// DNSSEC errors
public enum DNSSECError: Int, Codable {
    /// No signatures were found on the DNS message
    case noSignatures = 1
    /// The algorithm used is not supported by DNSKit
    case unsupportedAlgorithm = 2
    /// One or more domain did not produce signing keys
    case missingKeys = 3
    /// The key signing key for the root domain was not recognized and is untrusted
    case untrustedRootSigningKey = 4
    /// One or more signatures for resource records failed cryptographic validation
    case signatureFailed = 5
    /// One or more aspects of the response is invalid
    case invalidResponse = 6
    /// The signing key provided was invalid
    case badSigningKey = 7

    internal func error(_ description: String) -> Error {
        return Utils.MakeError(description, code: self.rawValue)
    }
}
