import Foundation

/// Describes the record data for an AAAA record
public struct AAAARecordData: RecordData {
    /// The IP address
    public let ipAddress: String

    internal init(ipAddress: Data) throws {
        if ipAddress.count > 16 {
            printError("[\(#fileID):\(#line)] Invalid IPv6 address: expecting >= 16 bytes got \(ipAddress.count)")
            throw Utils.MakeError("Invalid IPv6 address")
        }

        var buffer = ContiguousArray<Int8>(repeating: 0, count: Int(INET6_ADDRSTRLEN))
        self.ipAddress = ipAddress.withUnsafeBytes { data in
            let addr = data.assumingMemoryBound(to: sockaddr_in6.self)
            return buffer.withUnsafeMutableBufferPointer { buf in
                return String(cString: inet_ntop(AF_INET6, addr.baseAddress, buf.baseAddress, UInt32(buf.count)))
            }
        }
    }

    public var description: String {
        return self.ipAddress
    }
}
