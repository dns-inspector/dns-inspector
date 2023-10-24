import Foundation
import DNSKit

public struct RecordClass: Identifiable {
    public let name: String
    public let dnsKitValue: DNSRecordClass
    public var id = UUID()

    public static func fromDNSKit(_ dnsKitValue: DNSRecordClass) -> RecordClass! {
        switch dnsKitValue {
        case .IN:
            return RecordClass(name: "IN", dnsKitValue: .IN)
        case .CS:
            return RecordClass(name: "CS", dnsKitValue: .CS)
        case .CH:
            return RecordClass(name: "CH", dnsKitValue: .CH)
        case .HS:
            return RecordClass(name: "HS", dnsKitValue: .HS)
        default:
            fatalError("Unsupported DNSRecordType value")
        }
    }
}

public let RecordClasses: [RecordClass] = [
    RecordClass(name: "IN", dnsKitValue: .IN),
    RecordClass(name: "CS", dnsKitValue: .CS),
    RecordClass(name: "CH", dnsKitValue: .CH),
    RecordClass(name: "HS", dnsKitValue: .HS),
]
