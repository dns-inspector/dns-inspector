import Foundation

/// The DNS over HTTPS client.
internal class HTTPClient: IClient {
    fileprivate let url: URL
    fileprivate let transportOptions: TransportOptions

    required init(address: String, transportOptions: TransportOptions) throws {
        var urlString = String(address.lowercased())

        if !urlString.contains("://") {
            urlString = "https://\(urlString)"
        }

        guard let url = URL(string: urlString) else {
            throw Utils.MakeError("Invalid URL")
        }

        if url.scheme != "https" {
            throw Utils.MakeError("Invalid URL")
        }

        guard let host = url.host else {
            throw Utils.MakeError("Invalid URL")
        }
        if host.count == 0 {
            throw Utils.MakeError("Invalid URL")
        }

        self.url = url
        self.transportOptions = transportOptions
    }

    func send(message: Message, complete: @escaping (Result<Message, Error>) -> Void) {
        let timer = Timer.start()

        let questionData: Data
        do {
            questionData = try message.data()
        } catch {
            complete(.failure(error))
            return
        }

        printDebug("[\(#fileID):\(#line)] Question: \(questionData.hexEncodedString())")

        var urlString = self.url.absoluteString
        if urlString.contains("?") {
            urlString += "&"
        } else {
            urlString += "?"
        }
        urlString += "dns=\(questionData.base64UrlEncodedValue())"

        guard let url = URL(string: urlString) else {
            complete(.failure(Utils.MakeError("Invalid URL")))
            return
        }

        let request = URLRequest(url: url)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        sessionConfig.timeoutIntervalForResource = 5
        let session = URLSession(configuration: sessionConfig)
        printDebug("[\(#fileID):\(#line)] HTTP GET \(url)")
        session.dataTask(with: request) { oData, oResponse, oError in
            if let error = oError {
                printError("[\(#fileID):\(#line)] Response error \(error)")
                complete(.failure(error))
                return
            }

            guard let response = oResponse as? HTTPURLResponse else {
                printError("[\(#fileID):\(#line)] Response error")
                complete(.failure(Utils.MakeError("Bad response")))
                return
            }

            if response.statusCode != 200 {
                printError("[\(#fileID):\(#line)] HTTP \(response.statusCode)")
                complete(.failure(Utils.MakeError("HTTP \(response.statusCode)")))
                return
            }

            guard let contentType = response.value(forHTTPHeaderField: "Content-Type") else {
                printError("[\(#fileID):\(#line)] No content type header")
                complete(.failure(Utils.MakeError("No content type")))
                return
            }

            if contentType.lowercased() != "application/dns-message" {
                printError("[\(#fileID):\(#line)] Unsupported content type \(contentType)")
                complete(.failure(Utils.MakeError("Bad content type")))
                return
            }

            guard let data = oData else {
                printError("[\(#fileID):\(#line)] No data")
                complete(.failure(Utils.MakeError("Bad response")))
                return
            }

            if data.count > 4096 {
                printError("[\(#fileID):\(#line)] Excessive data size \(data.count)")
                complete(.failure(Utils.MakeError("Excessive data size")))
                return
            }

            let message: Message
            do {
                message = try Message(messageData: data, elapsed: timer.stop())
                printDebug("[\(#fileID):\(#line)] Answer \(data.hexEncodedString())")
                complete(.success(message))
            } catch {
                printError("[\(#fileID):\(#line)] Invalid DNS message returned: \(error)")
                complete(.failure(error))
            }
        }.resume()
    }

    func authenticate(message: Message, complete: @escaping (DNSSECResult) -> Void) throws {
        try DNSSECClient.authenticateMessage(message, client: self, complete: complete)
    }
}
