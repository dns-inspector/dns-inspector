import Foundation
import DNSKit

public struct PresetServer: Codable, Identifiable {
    public let type: TransportType
    public let address: String
    public var id = UUID()

    enum CodingKeys: CodingKey {
        case type, address
    }
}
