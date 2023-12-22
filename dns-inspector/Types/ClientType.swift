import Foundation
import DNSKit

public struct ClientType: Codable, Identifiable {
    public let name: String
    public let dnsKitValue: UInt
    public var id = UUID()

    public static func fromDNSKit(_ dnsKitValue: DNSClientType) -> ClientType! {
        switch dnsKitValue {
        case .UDP53:
            return ClientType(name: "DNS", dnsKitValue: DNSClientType.UDP53.rawValue)
        case .TCP53:
            return ClientType(name: "DNS", dnsKitValue: DNSClientType.TCP53.rawValue)
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
    ClientType(name: "DNS (UDP)", dnsKitValue: DNSClientType.UDP53.rawValue),
    ClientType(name: "DNS (TCP)", dnsKitValue: DNSClientType.TCP53.rawValue),
    ClientType(name: "HTTPS", dnsKitValue: DNSClientType.HTTPS.rawValue),
    ClientType(name: "TLS", dnsKitValue: DNSClientType.TLS.rawValue),
]
