import Foundation

/// Describes the result of DNSSEC message and chain validation.
///
/// To establish full "trust" of a message with DNSSEC two tests must pass; first the message data must match the signature,
/// and second the keys used to sign the data must build a chain up to the root zone.
///
/// If both of these tests pass, then you can be sure that the message was both not tampered with and issued by the correct authority.
public struct DNSSECResult {
    /// If signature data was validated against the keys provided
    public var signatureVerified: Bool = false
    /// If signature data was not verified, what error occured
    public var signatureError: Error?
    /// If the delegation chain from the root zone is trusted
    public var chainTrusted: Bool = false
    /// If the chain is not trusted, what error occured
    public var chainError: Error?
}
