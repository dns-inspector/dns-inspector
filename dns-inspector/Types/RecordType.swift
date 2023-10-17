import Foundation
import DNSKit

public struct RecordType: Identifiable {
    public let name: String
    public let dnsKitValue: DNSRecordType
    public var id = UUID()
}

public let RecordTypes: [RecordType] = [
    RecordType(name: "A", dnsKitValue: .A),
    RecordType(name: "AAAA", dnsKitValue: .AAAA),
    RecordType(name: "APL", dnsKitValue: .APL),
    RecordType(name: "SRV", dnsKitValue: .SRV),
    RecordType(name: "TXT", dnsKitValue: .TXT),
    RecordType(name: "MX", dnsKitValue: .MX),
    RecordType(name: "PTR", dnsKitValue: .PTR),
]
