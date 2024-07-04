import Foundation
import Network

/// The DNS over TLS client.
internal class TLSClient: IClient {
    fileprivate let address: SocketAddress
    fileprivate let transportOptions: TransportOptions

    required init(address: String, transportOptions: TransportOptions) throws {
        self.address = try SocketAddress(addressString: address)
        self.transportOptions = transportOptions
    }

    func send(message: Message, complete: @escaping (Result<Message, any Error>) -> Void) {
        let timer = Timer.start()

        let questionData: Data
        do {
            questionData = try message.data()
        } catch {
            complete(.failure(error))
            return
        }

        var messageData = Data()
        let length = UInt16(questionData.count).bigEndian
        withUnsafePointer(to: length) { p in
            messageData.append(Data(bytes: p, count: 2))
        }
        messageData.append(questionData)

        printDebug("[\(#fileID):\(#line)] Question: \(questionData.hexEncodedString())")

        let queue = DispatchQueue(label: "io.ecn.dnskit.tlsclient")
        let connection = NWConnection(to: NWEndpoint.socketAddress(self.address, defaultPort: 853), using: .tls)
        connection.stateUpdateHandler = { state in
            switch state {
            case .waiting(let error):
                complete(.failure(error))
                connection.cancel()
            case .ready:
                printDebug("[\(#fileID):\(#line)] NWConnection ready")

                // Read 2 bytes for the length
                connection.receive(minimumIncompleteLength: 2, maximumLength: 2) { oLengthContent, _, _, lengthError in
                    printDebug("[\(#fileID):\(#line)] Read 2")
                    if let error = lengthError {
                        printError("[\(#fileID):\(#line)] Error recieving data: \(error)")
                        complete(.failure(error))
                        connection.cancel()
                        return
                    }

                    guard let lengthContent = oLengthContent else {
                        printError("[\(#fileID):\(#line)] No data returned")
                        complete(.failure(Utils.MakeError("No content")))
                        connection.cancel()
                        return
                    }

                    let length = lengthContent.withUnsafeBytes { buf in
                        return buf.loadUnaligned(fromByteOffset: 0, as: UInt16.self).bigEndian
                    }
                    if length == 0 {
                        printError("[\(#fileID):\(#line)] Length of 0 returned, aborting")
                        complete(.failure(Utils.MakeError("No content")))
                        connection.cancel()
                        return
                    }

                    // Read the remaining data
                    connection.receive(minimumIncompleteLength: Int(length), maximumLength: Int(length)) { oMessageContent, _, _, messageError in
                        printDebug("[\(#fileID):\(#line)] Read \(length)")

                        if let error = messageError {
                            printError("[\(#fileID):\(#line)] Error recieving data: \(error)")
                            complete(.failure(error))
                            connection.cancel()
                            return
                        }

                        guard let messageContent = oMessageContent else {
                            printError("[\(#fileID):\(#line)] No data returned")
                            complete(.failure(Utils.MakeError("No content")))
                            connection.cancel()
                            return
                        }

                        if messageContent.count != length {
                            printError("[\(#fileID):\(#line)] Reported and actual length do not match. Reported: \(length), actual: \(messageContent.count)")
                            complete(.failure(Utils.MakeError("No content")))
                            connection.cancel()
                            return
                        }

                        let message: Message
                        do {
                            message = try Message(messageData: messageContent, elapsed: timer.stop())
                        } catch {
                            printError("[\(#fileID):\(#line)] Invalid DNS message returned: \(error)")
                            complete(.failure(error))
                            connection.cancel()
                            return
                        }

                        printDebug("[\(#fileID):\(#line)] Answer: \(messageContent.hexEncodedString())")

                        complete(.success(message))
                        connection.cancel()
                        return
                    }
                }

                connection.send(content: messageData, completion: NWConnection.SendCompletion.contentProcessed({ oError in
                    printDebug("[\(#fileID):\(#line)] Wrote \(messageData.count)")
                    if let error = oError {
                        complete(.failure(error))
                        connection.cancel()
                        return
                    }
                }))
            case .failed(let error):
                printError("[\(#fileID):\(#line)] NWConnection failed with error: \(error)")
                complete(.failure(error))
                connection.cancel()
            case .cancelled:
                printInformation("[\(#fileID):\(#line)] NWConnection cancelled")
            default:
                break
            }
        }
        printDebug("[\(#fileID):\(#line)] Connecting to \(self.address)")
        connection.start(queue: queue)
    }

    func authenticate(message: Message, complete: @escaping (DNSSECResult) -> Void) throws {
        try DNSSECClient.authenticateMessage(message, client: self, complete: complete)
    }
}
