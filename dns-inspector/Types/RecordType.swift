import Foundation
import DNSKit

public struct RecordType: Identifiable {
    public let name: String
    public let dnsKitValue: DNSRecordType
    public var id = UUID()

    public static func fromDNSKit(_ dnsKitValue: DNSRecordType) -> RecordType! {
        switch dnsKitValue {
        case .A:
            return RecordType(name: "A", dnsKitValue: .A)
        case .CNAME:
            return RecordType(name: "CNAME", dnsKitValue: .CNAME)
        case .AAAA:
            return RecordType(name: "AAAA", dnsKitValue: .AAAA)
        case .APL:
            return RecordType(name: "APL", dnsKitValue: .APL)
        case .SRV:
            return RecordType(name: "SRV", dnsKitValue: .SRV)
        case .TXT:
            return RecordType(name: "TXT", dnsKitValue: .TXT)
        case .MX:
            return RecordType(name: "MX", dnsKitValue: .MX)
        case .PTR:
            return RecordType(name: "PTR", dnsKitValue: .PTR)
        default:
            fatalError("Unsupported DNSRecordType value")
        }
    }
}

public let RecordTypes: [RecordType] = [
    RecordType(name: "A", dnsKitValue: .A),
    RecordType(name: "CNAME", dnsKitValue: .CNAME),
    RecordType(name: "AAAA", dnsKitValue: .AAAA),
    RecordType(name: "APL", dnsKitValue: .APL),
    RecordType(name: "SRV", dnsKitValue: .SRV),
    RecordType(name: "TXT", dnsKitValue: .TXT),
    RecordType(name: "MX", dnsKitValue: .MX),
    RecordType(name: "PTR", dnsKitValue: .PTR),
]
