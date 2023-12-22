import Foundation
import DNSKit

public struct PresetServer: Codable, Identifiable {
    public let type: UInt
    public let address: String
    public var id = UUID()

    enum CodingKeys: CodingKey {
        case type, address
    }

    public func clientType() -> ClientType! {
        return ClientType.fromDNSKit(DNSClientType(rawValue: self.type)!)
    }
}
