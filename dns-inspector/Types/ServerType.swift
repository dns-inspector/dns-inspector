import Foundation
import DNSKit

public struct ServerType: Codable, Identifiable {
    public let name: String
    public let dnsKitValue: UInt
    public var id = UUID()

    public static func fromDNSKit(_ dnsKitValue: DNSServerType) -> ServerType! {
        switch dnsKitValue {
        case .UDP53:
            return ServerType(name: "DNS", dnsKitValue: DNSServerType.UDP53.rawValue)
        case .TCP53:
            return ServerType(name: "DNS", dnsKitValue: DNSServerType.TCP53.rawValue)
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
    ServerType(name: "DNS (UDP)", dnsKitValue: DNSServerType.UDP53.rawValue),
    ServerType(name: "DNS (TCP)", dnsKitValue: DNSServerType.TCP53.rawValue),
    ServerType(name: "HTTPS", dnsKitValue: DNSServerType.HTTPS.rawValue),
    ServerType(name: "TLS", dnsKitValue: DNSServerType.TLS.rawValue),
]
