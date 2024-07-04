import Foundation

internal enum IPAddressVersion: Int {
    case v4 = 4
    case v6 = 6
}

internal class SocketAddress: CustomStringConvertible, CustomDebugStringConvertible {
    let ipAddress: String
    let port: UInt16?
    let version: IPAddressVersion

    fileprivate static let portSuffixPattern = NSRegularExpression("\\]?:\\d{1,5}$", options: .caseInsensitive)
    fileprivate static let ipv4Pattern = NSRegularExpression("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}(\\:[0-9]{1,5})?$", options: .caseInsensitive)
    fileprivate static let ipv6Pattern = NSRegularExpression("^\\[?(([0-9a-f\\:]+){1,4}){1,8}\\]?(\\:[0-9]{1,5})?$", options: .caseInsensitive)

    /// Create a new SocketAddress instance from the given socket address string
    /// - Parameter addressString: The address string
    ///
    /// Acceppted IP address formats:
    ///
    /// **IPv4:**
    /// - `n.n.n.n`
    /// - `n.n.n.n:port`
    ///
    /// **IPv6:**
    /// - `x::`
    /// - `[x::]:port`
    ///
    init(addressString: String) throws {
        if SocketAddress.ipv4Pattern.matches(in: addressString, range: NSRange(location: 0, length: addressString.count)).count > 0 {
            var ipAddress = ""

            let portMatches = SocketAddress.portSuffixPattern.matches(in: addressString, range: NSRange(location: 0, length: addressString.count))
            if portMatches.count > 1 {
                printError("[\(#fileID):\(#line)] Invalid IPv4 address: \(addressString)")
                throw Utils.MakeError("Invalid IPv4 Address")
            } else if portMatches.count == 1 {
                let portStr = String(addressString.suffix(portMatches[0].range.length-1))
                ipAddress = String(addressString.prefix(portMatches[0].range.location))

                guard let port = UInt16(portStr) else {
                    printError("[\(#fileID):\(#line)] Invalid port number from address: \(addressString)")
                    throw Utils.MakeError("Invalid port number")
                }

                self.port = port
            } else {
                ipAddress = addressString
                self.port = nil
            }

            var sa: sockaddr_in = .init()
            if inet_pton(AF_INET, ipAddress, &sa.sin_addr) == 0 {
                printError("[\(#fileID):\(#line)] Invalid IPv4 address: \(addressString)")
                throw Utils.MakeError("Invalid IPv4 Address")
            }

            self.ipAddress = ipAddress
            self.version = .v4
        } else if SocketAddress.ipv6Pattern.matches(in: addressString, range: NSRange(location: 0, length: addressString.count)).count > 0 {
            var ipAddress = ""

            // Check for port suffix. IPv6 addresses must be wrapped with [] when a port is specified
            let portMatches = SocketAddress.portSuffixPattern.matches(in: addressString, range: NSRange(location: 0, length: addressString.count))
            if addressString.first == "[" && portMatches.count == 1 {
                let portStr = String(addressString.suffix(portMatches[0].range.length-2))
                ipAddress = String(addressString.prefix(portMatches[0].range.location).dropFirst())

                guard let port = UInt16(portStr) else {
                    printError("[\(#fileID):\(#line)] Invalid port number from address: \(addressString)")
                    throw Utils.MakeError("Invalid port number")
                }

                self.port = port
            } else {
                ipAddress = addressString
                self.port = nil
            }

            var sa: sockaddr_in6 = .init()
            if inet_pton(AF_INET6, ipAddress, &sa.sin6_addr) == 0 {
                printError("[\(#fileID):\(#line)] Invalid IPv6 address: \(addressString)")
                throw Utils.MakeError("Invalid IPv6 Address")
            }

            self.ipAddress = ipAddress
            self.version = .v6
        } else {
            printError("[\(#fileID):\(#line)] Unrecognized IP address: \(addressString)")
            throw Utils.MakeError("Unknown IP address format")
        }
    }

    var description: String {
        switch self.version {
        case .v4:
            if let port = self.port {
                return "\(self.ipAddress):\(port)"
            } else {
                return "\(self.ipAddress)"
            }
        case .v6:
            if let port = self.port {
                return "[\(self.ipAddress)]:\(port)"
            } else {
                return "\(self.ipAddress)"
            }
        }
    }

    var debugDescription: String {
        return description
    }
}
