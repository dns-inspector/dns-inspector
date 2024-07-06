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
        let semaphore = DispatchSemaphore(value: 0)
        var didComplete = false

        let connection = NWConnection(to: NWEndpoint.socketAddress(self.address, defaultPort: 853), using: .tls)
        connection.stateUpdateHandler = { state in
            printDebug("[\(#fileID):\(#line)] NWConnection state \(String(describing: state))")

            let completeRequest: (Result<Message, any Error>) -> Void = { result in
                complete(result)
                connection.cancel()
                didComplete = true
                semaphore.signal()
            }

            switch state {
            case .waiting(let error):
                printError("[\(#fileID):\(#line)] Connection error: \(error)")
                completeRequest(.failure(error))
            case .ready:
                printDebug("[\(#fileID):\(#line)] NWConnection ready")

                // Read 2 bytes for the length
                connection.receive(minimumIncompleteLength: 2, maximumLength: 2) { oLengthContent, _, _, lengthError in
                    printDebug("[\(#fileID):\(#line)] Read 2")
                    if let error = lengthError {
                        printError("[\(#fileID):\(#line)] Error recieving data: \(error)")
                        completeRequest(.failure(error))
                        return
                    }

                    guard let lengthContent = oLengthContent else {
                        printError("[\(#fileID):\(#line)] No data returned")
                        completeRequest(.failure(Utils.MakeError("No content")))
                        return
                    }

                    let length = lengthContent.withUnsafeBytes { buf in
                        return buf.loadUnaligned(fromByteOffset: 0, as: UInt16.self).bigEndian
                    }
                    if length == 0 {
                        printError("[\(#fileID):\(#line)] Length of 0 returned, aborting")
                        completeRequest(.failure(Utils.MakeError("No content")))
                        return
                    }

                    // Read the remaining data
                    connection.receive(minimumIncompleteLength: Int(length), maximumLength: Int(length)) { oMessageContent, _, _, messageError in
                        printDebug("[\(#fileID):\(#line)] Read \(length)")

                        if let error = messageError {
                            printError("[\(#fileID):\(#line)] Error recieving data: \(error)")
                            completeRequest(.failure(error))
                            return
                        }

                        guard let messageContent = oMessageContent else {
                            printError("[\(#fileID):\(#line)] No data returned")
                            completeRequest(.failure(Utils.MakeError("No content")))
                            return
                        }

                        if messageContent.count != length {
                            printError("[\(#fileID):\(#line)] Reported and actual length do not match. Reported: \(length), actual: \(messageContent.count)")
                            completeRequest(.failure(Utils.MakeError("No content")))
                            return
                        }

                        let message: Message
                        do {
                            message = try Message(messageData: messageContent, elapsed: timer.stop())
                        } catch {
                            printError("[\(#fileID):\(#line)] Invalid DNS message returned: \(error)")
                            completeRequest(.failure(error))
                            return
                        }

                        printDebug("[\(#fileID):\(#line)] Answer: \(messageContent.hexEncodedString())")

                        completeRequest(.success(message))
                        return
                    }
                }

                connection.send(content: messageData, completion: NWConnection.SendCompletion.contentProcessed({ oError in
                    printDebug("[\(#fileID):\(#line)] Wrote \(messageData.count)")
                    if let error = oError {
                        completeRequest(.failure(error))
                        return
                    }
                }))
            case .failed(let error):
                printError("[\(#fileID):\(#line)] NWConnection failed with error: \(error)")
                completeRequest(.failure(error))
            case .cancelled:
                printInformation("[\(#fileID):\(#line)] NWConnection cancelled")
            default:
                break
            }
        }
        printDebug("[\(#fileID):\(#line)] Connecting to \(self.address)")
        connection.start(queue: queue)

        _ = semaphore.wait(timeout: self.transportOptions.timeoutDispatchTime)
        if !didComplete {
            connection.cancel()
            printError("[\(#fileID):\(#line)] Connection timed out")
            complete(.failure(Utils.MakeError("Connection timed out")))
            return
        }
    }

    func authenticate(message: Message, complete: @escaping (DNSSECResult) -> Void) throws {
        try DNSSECClient.authenticateMessage(message, client: self, complete: complete)
    }
}
