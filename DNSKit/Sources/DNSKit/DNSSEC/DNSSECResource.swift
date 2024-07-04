import Foundation

/// Describes all DNSSEC resources for a zone
internal struct DNSSECResource {
    internal let name: String
    internal let dnsKeys: [Answer]
    internal let keySignature: Answer
    internal let ds: Answer?
    internal let dsSignature: Answer?
}
