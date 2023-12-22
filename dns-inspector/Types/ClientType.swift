import Foundation
import DNSKit

public struct ClientType: Codable, Identifiable {
    public let name: String
    public let dnsKitValue: UInt
    public var id = UUID()

    public static func fromDNSKit(_ dnsKitValue: DNSClientType) -> ClientType! {
        switch dnsKitValue {
        case .DNS:
            return ClientType(name: "DNS", dnsKitValue: DNSClientType.DNS.rawValue)
        case .HTTPS:
            return ClientType(name: "HTTPS", dnsKitValue: DNSClientType.HTTPS.rawValue)
        case .TLS:
            return ClientType(name: "TLS", dnsKitValue: DNSClientType.TLS.rawValue)
        default:
            fatalError("Unsupported DNSClientType value")
        }
    }
}

public let ClientTypes: [ClientType] = [
    ClientType(name: "DNS", dnsKitValue: DNSClientType.DNS.rawValue),
    ClientType(name: "HTTPS", dnsKitValue: DNSClientType.HTTPS.rawValue),
    ClientType(name: "TLS", dnsKitValue: DNSClientType.TLS.rawValue),
]
