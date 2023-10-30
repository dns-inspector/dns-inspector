import Foundation
import DNSKit

public struct ResponseCode: Identifiable {
    public let name: String
    public let dnsKitValue: DNSResponseCode
    public var id = UUID()

    public static func fromDNSKit(_ dnsKitValue: DNSResponseCode) -> ResponseCode! {
        switch dnsKitValue {
        case .success:
            return ResponseCode(name: "OK", dnsKitValue: .success)
        case .FORMERR:
            return ResponseCode(name: "FORMERR", dnsKitValue: .FORMERR)
        case .SERVFAIL:
            return ResponseCode(name: "SERVFAIL", dnsKitValue: .SERVFAIL)
        case .NXDOMAIN:
            return ResponseCode(name: "NXDOMAIN", dnsKitValue: .NXDOMAIN)
        case .NOTIMP:
            return ResponseCode(name: "NOTIMP", dnsKitValue: .NOTIMP)
        case .REFUSED:
            return ResponseCode(name: "REFUSED", dnsKitValue: .REFUSED)
        case .YXDOMAIN:
            return ResponseCode(name: "YXDOMAIN", dnsKitValue: .YXDOMAIN)
        case .XRRSET:
            return ResponseCode(name: "XRRSET", dnsKitValue: .XRRSET)
        case .NOTAUTH:
            return ResponseCode(name: "NOTAUTH", dnsKitValue: .NOTAUTH)
        case .NOTZONE:
            return ResponseCode(name: "NOTZONE", dnsKitValue: .NOTZONE)
        default:
            fatalError("Unsupported DNSResponseCode value")
        }
    }
}

public let ResponseCodes: [ResponseCode] = [
    ResponseCode(name: "OK", dnsKitValue: .success),
    ResponseCode(name: "FORMERR", dnsKitValue: .FORMERR),
    ResponseCode(name: "SERVFAIL", dnsKitValue: .SERVFAIL),
    ResponseCode(name: "NXDOMAIN", dnsKitValue: .NXDOMAIN),
    ResponseCode(name: "NOTIMP", dnsKitValue: .NOTIMP),
    ResponseCode(name: "REFUSED", dnsKitValue: .REFUSED),
    ResponseCode(name: "YXDOMAIN", dnsKitValue: .YXDOMAIN),
    ResponseCode(name: "XRRSET", dnsKitValue: .XRRSET),
    ResponseCode(name: "NOTAUTH", dnsKitValue: .NOTAUTH),
    ResponseCode(name: "NOTZONE", dnsKitValue: .NOTZONE),
]
