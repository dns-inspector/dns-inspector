import Foundation
import DNSKit

public struct ServerType: Identifiable {
    public let name: String
    public let dnsKitValue: DNSServerType
    public var id = UUID()
}

public let ServerTypes: [ServerType] = [
    ServerType(name: "DNS", dnsKitValue: .DNS),
    ServerType(name: "HTTPS", dnsKitValue: .HTTPS),
    ServerType(name: "TLS", dnsKitValue: .TLS),
]
