import Foundation
import Network

/// WHOIS related utilities
public struct WHOIS {
    private static let registrarLinePattern = NSRegularExpression("registrar whois server:.*\r?\n", options: .caseInsensitive)

    /// Perform a WHOIS lookup on the given domain name
    /// - Parameter domain: The domain name to query
    /// - Returns: Returns the WHOIS response data
    /// - Throws: Will throw if unable to perform the lookup
    ///
    /// > Tip: WHOIS data is always returned as an human-readable formatted string.
    public static func lookup(_ domain: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            self.lookup(domain) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Perform a WHOIS lookup on the given domain name
    /// - Parameters:
    ///   - domain: The domain name to query
    ///   - complete: Callback called when the lookup has completed with a result or an error.
    ///
    /// > Tip: WHOIS data is always returned as an human-readable formatted string.
    public static func lookup(_ domain: String, complete: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let (oServer, oBareDomain) = WHOIS.getLookupHost(for: domain)
            guard let server = oServer else {
                printError("[\(#fileID):\(#line)] Unsuported TLD for WHOIS lookup: \(domain)")
                complete(.failure(Utils.MakeError("TLD does not support WHOIS")))
                return
            }
            guard let bareDomain = oBareDomain else {
                printError("[\(#fileID):\(#line)] Unsuported TLD for WHOIS lookup: \(domain)")
                complete(.failure(Utils.MakeError("TLD does not support WHOIS")))
                return
            }

            printDebug("[\(#fileID):\(#line)] Performing WHOIS lookup for \(domain) on \(server)")
            WHOIS.lookup(bareDomain, server: server, depth: 1, complete: complete)
        }
    }

    internal static func lookup(_ domain: String, server: String, depth: Int, complete: @escaping (Result<String, Error>) -> Void) {
        if depth > 10 {
            printError("[\(#fileID):\(#line)] Aborting WHOIS request due to too many redirects")
            complete(.failure(Utils.MakeError("Too many redirects")))
            return
        }

        printDebug("[\(#fileID):\(#line)] Connecting to \(server):43...")
        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host.name(server, nil), port: NWEndpoint.Port(rawValue: 43)!)
        let connection = NWConnection(to: endpoint, using: NWParameters.init(tls: nil, tcp: NWProtocolTCP.Options()))
        connection.stateUpdateHandler = { state in
            printDebug("[\(#fileID):\(#line)] NWConnection \(String(describing: state))")
            switch state {
            case .failed(let error):
                printError("[\(#fileID):\(#line)] Error sending WHOIS query to \(server): \(error)")
                complete(.failure(error))
            case .ready:
                connection.receive(minimumIncompleteLength: 2, maximumLength: 4096) { oContent, _, _, oError in
                    if let error = oError {
                        printError("[\(#fileID):\(#line)] Error sending WHOIS query to \(server): \(error)")
                        complete(.failure(error))
                        connection.cancel()
                        return
                    }
                    guard let data = oContent else {
                        printError("[\(#fileID):\(#line)] Error sending WHOIS query to \(server): No data")
                        complete(.failure(Utils.MakeError("No data")))
                        connection.cancel()
                        return
                    }

                    let response = String(decoding: data, as: UTF8.self)

                    // Check if there is a server we should follow to
                    var nextServer: String?
                    if let match = WHOIS.registrarLinePattern.firstMatch(in: response, range: NSRange(location: 0, length: response.count)) {
                        let line = response.substring(with: match.range)
                        let parts = String(line).split(separator: ":")
                        if parts.count != 2 {
                            printWarning("[\(#fileID):\(#line)] Unknown format of registrar WHOIS server line: \(line)")
                        }

                        var followServer = String(parts[1])
                        followServer = followServer.replacingOccurrences(of: " ", with: "")
                        followServer = followServer.replacingOccurrences(of: "\r", with: "")
                        followServer = followServer.replacingOccurrences(of: "\n", with: "")

                        if followServer.hasPrefix("https://") {
                            followServer = followServer.replacingOccurrences(of: "https://", with: "")
                        } else if followServer.hasPrefix("http://") {
                            followServer = followServer.replacingOccurrences(of: "http://", with: "")
                        }
                        nextServer = followServer
                        printDebug("[\(#fileID):\(#line)] Following redirect to \(followServer)")
                    }

                    guard let followServer = nextServer else {
                        complete(.success(response))
                        connection.cancel()
                        return
                    }

                    if followServer.lowercased() == server.lowercased() {
                        complete(.success(response))
                        connection.cancel()
                        return
                    }

                    connection.cancel()
                    WHOIS.lookup(domain, server: followServer, depth: depth+1, complete: complete)
                }
                connection.send(content: "\(domain)\r\n".data(using: .ascii), completion: NWConnection.SendCompletion.contentProcessed({ oError in
                    if let error = oError {
                        printError("[\(#fileID):\(#line)] Error sending WHOIS query to \(server): \(error)")
                        complete(.failure(error))
                        connection.cancel()
                    }
                }))
            default:
                break
            }
        }
        connection.start(queue: DispatchQueue.global(qos: .userInitiated))
    }

    /// Get the WHOIS server address for the given domain name.
    /// - Parameter domain: The domain name to query for
    /// - Returns: A tuple of two optional strings. The first is the lookup server host address, the second is the bare URL for querying (without any subdomains).
    public static func getLookupHost(for domain: String) -> (String?, String?) {
        if domain.count == 0 || domain.count > 250 {
            return (nil, nil)
        }

        var input = domain.lowercased()
        if input.hasSuffix(".") {
            input = String(input.dropLast())
        }

        var parts = input.split(separator: ".")
        guard let last = parts.last else {
            return (nil, nil)
        }
        var tld = String(last)

        // First check if the domain uses a gTLD. gTLD's are always one-level
        let newGtlds = WHOIS.getNewGtlds()
        for gtld in newGtlds {
            if gtld != tld {
                continue
            }

            let bareDomain = "\(parts[parts.count-2]).\(tld)"
            return ("whois.nic.\(tld)", bareDomain)
        }

        let tldServ = WHOIS.getTldServ()

        // Next iterate through each part of the input domain name, cutting off one part each time until we find a match
        // or we've run out of parts of the name.
        while true {
            let partRemoved = parts.remove(at: 0)
            if parts.count == 0 {
                break
            }

            tld = ".\(parts.joined(separator: "."))"

            if let serverName = tldServ[tld] {
                let bareName = "\(partRemoved)\(tld)"
                return (serverName, bareName)
            }
        }

        return (nil, nil)
    }
}
