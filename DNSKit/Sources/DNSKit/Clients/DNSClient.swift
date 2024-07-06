import Foundation
import Network

/// The traditional DNS client. Supports both UDP and TCP.
internal class DNSClient: IClient {
    internal let address: SocketAddress
    internal let transportOptions: TransportOptions

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

        printDebug("[\(#fileID):\(#line)] Question: \(questionData.hexEncodedString())")

        var messageData = Data()
        if self.transportOptions.dnsPrefersTcp {
            let length = UInt16(questionData.count).bigEndian
            withUnsafePointer(to: length) { p in
                messageData.append(Data(bytes: p, count: 2))
            }
        }
        messageData.append(questionData)

        let queue = DispatchQueue(label: "io.ecn.dnskit.tlsclient")
        let semaphore = DispatchSemaphore(value: 0)
        var didComplete = false

        let connection = NWConnection(to: NWEndpoint.socketAddress(self.address, defaultPort: 53), using: self.transportOptions.dnsPrefersTcp ? .tcp : .udp)
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
                let minLength = 2
                let maxLength = self.transportOptions.dnsPrefersTcp ? 2 : 4096

                // If using TCP, read 2 bytes for the length. If using UDP, read the entire datagram
                connection.receive(minimumIncompleteLength: minLength, maximumLength: maxLength) { oFirstData, _, _, firstError in
                    printDebug("[\(#fileID):\(#line)] Read \(minLength)")

                    if let error = firstError {
                        printError("[\(#fileID):\(#line)] Error recieving data: \(error)")
                        completeRequest(.failure(error))
                        return
                    }

                    guard let firstData = oFirstData else {
                        printError("[\(#fileID):\(#line)] No data returned")
                        completeRequest(.failure(Utils.MakeError("No content")))
                        return
                    }

                    if !self.transportOptions.dnsPrefersTcp {
                        let message: Message
                        do {
                            message = try Message(messageData: firstData, elapsed: timer.stop())
                        } catch {
                            printError("[\(#fileID):\(#line)] Invalid DNS message returned: \(error)")
                            completeRequest(.failure(error))
                            return
                        }

                        printDebug("[\(#fileID):\(#line)] Answer: \(firstData.hexEncodedString())")

                        completeRequest(.success(message))
                        return
                    }

                    let length = firstData.withUnsafeBytes { buf in
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
                        printError("[\(#fileID):\(#line)] Error writing question: \(error)")
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
