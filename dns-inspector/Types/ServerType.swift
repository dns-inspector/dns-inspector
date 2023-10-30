import Foundation
import DNSKit

public struct ServerType: Codable, Identifiable {
    public let name: String
    public let dnsKitValue: UInt
    public var id = UUID()

    public static func fromDNSKit(_ dnsKitValue: DNSServerType) -> ServerType! {
        switch dnsKitValue {
        case .DNS:
            return ServerType(name: "DNS", dnsKitValue: DNSServerType.DNS.rawValue)
        case .HTTPS:
            return ServerType(name: "HTTPS", dnsKitValue: DNSServerType.HTTPS.rawValue)
        case .TLS:
            return ServerType(name: "TLS", dnsKitValue: DNSServerType.TLS.rawValue)
        default:
            fatalError("Unsupported DNSServerType value")
        }
    }
}

public let ServerTypes: [ServerType] = [
    ServerType(name: "DNS", dnsKitValue: DNSServerType.DNS.rawValue),
    ServerType(name: "HTTPS", dnsKitValue: DNSServerType.HTTPS.rawValue),
    ServerType(name: "TLS", dnsKitValue: DNSServerType.TLS.rawValue),
]
