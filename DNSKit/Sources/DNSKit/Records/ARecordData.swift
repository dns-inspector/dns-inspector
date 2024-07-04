import Foundation

/// Describes the record data for an A record
public struct ARecordData: RecordData {
    /// The IP address
    public let ipAddress: String

    internal init(ipAddress: Data) throws {
        if ipAddress.count > 4 {
            printError("[\(#fileID):\(#line)] Invalid IPv4 address: expecting >= 4 bytes got \(ipAddress.count)")
            throw Utils.MakeError("Invalid IPv4 address")
        }

        var buffer = ContiguousArray<Int8>(repeating: 0, count: Int(INET_ADDRSTRLEN))
        self.ipAddress = ipAddress.withUnsafeBytes { data in
            let addr = data.assumingMemoryBound(to: sockaddr_in.self)
            return buffer.withUnsafeMutableBufferPointer { buf in
                return String(cString: inet_ntop(AF_INET, addr.baseAddress, buf.baseAddress, UInt32(buf.count)))
            }
        }
    }

    public var description: String {
        return self.ipAddress
    }
}
