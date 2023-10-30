import Foundation
import DNSKit

public struct OperationCode: Identifiable {
    public let name: String
    public let dnsKitValue: DNSOperationCode
    public var id = UUID()

    public static func fromDNSKit(_ dnsKitValue: DNSOperationCode) -> OperationCode! {
        switch dnsKitValue {
        case .query:
            return OperationCode(name: "QUERY", dnsKitValue: .query)
        case .iQuery:
            return OperationCode(name: "IQUERY", dnsKitValue: .iQuery)
        case .status:
            return OperationCode(name: "STATUS", dnsKitValue: .status)
        case .notify:
            return OperationCode(name: "NOTIFY", dnsKitValue: .notify)
        case .update:
            return OperationCode(name: "UPDATE", dnsKitValue: .update)
        default:
            fatalError("Unsupported DNSOperationCode value")
        }
    }
}

public let OperationCodes: [OperationCode] = [
    OperationCode(name: "QUERY", dnsKitValue: .query),
    OperationCode(name: "IQUERY", dnsKitValue: .iQuery),
    OperationCode(name: "STATUS", dnsKitValue: .status),
    OperationCode(name: "NOTIFY", dnsKitValue: .notify),
    OperationCode(name: "UPDATE", dnsKitValue: .update),
]
