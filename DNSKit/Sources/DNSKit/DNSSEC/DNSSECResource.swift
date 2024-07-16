import Foundation

/// Describes all DNSSEC resources for a zone
public struct DNSSECResource {
    /// The zone name
    public let zone: String
    /// DNSKEY answers for this zone
    public let dnsKeys: [Answer]
    /// Signatures for the DNSKEY response
    public let keySignature: Answer
    /// DS answer for this zone
    public let ds: Answer?
    /// SIgnatures for the DS response
    public let dsSignature: Answer?
}
