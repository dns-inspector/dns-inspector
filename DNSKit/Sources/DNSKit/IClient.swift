import Foundation

/// The internal DNS client protocol
internal protocol IClient {
    /// Create a new instance of the DNS client
    /// - Parameters:
    ///   - address: The DNS server address
    ///   - transportOptions: Transport options
    init(address: String, transportOptions: TransportOptions) throws

    /// Send a DNS message
    /// - Parameters:
    ///   - message: The message to send
    ///   - complete: Callback called when complete, with either the response message or an error
    func send(message: Message, complete: @escaping (Result<Message, Error>) -> Void)

    /// Authenticate the given DNS message
    /// - Parameters:
    ///   - message: The message to authenticate. This message must be a response to a query where ``QueryOptions/dnssecRequested`` was set
    ///   - complete: Callback called when complete with the result of the authentication
    /// - Throws: Will throw on any fatal error while collecting required information.
    /// This method will perform multiple queries in relation to the number of zones within the name.
    /// > Warning: DNSSEC authentication is a new feature to DNSKit and should not be relied upon for any critical situations.
    func authenticate(message: Message, complete: @escaping (DNSSECResult) -> Void) throws
}
