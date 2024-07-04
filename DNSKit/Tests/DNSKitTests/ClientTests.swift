import XCTest
@testable import DNSKit

protocol IClientTests {
    func testQuery() async throws
    func testQueryNXDOMAIN() async throws
    func testAuthenticateMessage() async throws
    func testRandomData() async throws
    func testLengthOver() async throws
    func testLengthUnder() async throws
}

final class ClientTests {
    let client: IClient

    init(transportType: TransportType, transportOptions: TransportOptions = TransportOptions(), serverAddress: String) throws {
        switch transportType {
        case .DNS:
            self.client = try DNSClient(address: serverAddress, transportOptions: transportOptions)
        case .TLS:
            self.client = try TLSClient(address: serverAddress, transportOptions: transportOptions)
        case .HTTPS:
            self.client = try HTTPClient(address: serverAddress, transportOptions: transportOptions)
        }
    }

    func testQuery() async throws {
        let query = Query(client: client, recordType: .A, name: "example.com")
        let reply = try await query.execute()
        XCTAssertEqual(reply.answers.count, 1)
    }

    func testQueryNXDOMAIN() async throws {
        let query = Query(client: client, recordType: .A, name: "if-you-register-this-domain-im-going-to-be-very-angry.com")
        let reply = try await query.execute()
        XCTAssertEqual(reply.responseCode, .NXDOMAIN)
    }

    func testAuthenticateMessage() async throws {
        let query = Query(client: client, recordType: .A, name: "example.com", queryOptions: QueryOptions(dnssecRequested: true))
        let reply = try await query.execute()
        let result = try await query.authenticate(message: reply)
        XCTAssertTrue(result.chainTrusted)
    }

    func testRandomData() async throws {
        let query = Query(client: client, recordType: .A, name: "random.example.com")
        do {
            _ = try await query.execute()
            XCTFail("No failure seen for random data")
        } catch {
            //
        }
    }

    func testLengthOver() async throws {
        let query = Query(client: client, recordType: .A, name: "length.over.example.com")
        do {
            _ = try await query.execute()
            XCTFail("No failure seen for random data")
        } catch {
            //
        }
    }

    func testLengthUnder() async throws {
        let query = Query(client: client, recordType: .A, name: "length.under.example.com")
        do {
            _ = try await query.execute()
            XCTFail("No failure seen for random data")
        } catch {
            //
        }
    }
}
