import Foundation
import Network

internal extension NWEndpoint {
    static func socketAddress(_ socketAddress: SocketAddress, defaultPort: UInt16) -> NWEndpoint {
        let host: NWEndpoint.Host = socketAddress.version == .v4 ? .ipv4(IPv4Address(socketAddress.ipAddress)!) : .ipv6(IPv6Address(socketAddress.ipAddress)!)
        let port: NWEndpoint.Port = .init(rawValue: socketAddress.port ?? defaultPort)!
        return NWEndpoint.hostPort(host: host, port: port)
    }
}
