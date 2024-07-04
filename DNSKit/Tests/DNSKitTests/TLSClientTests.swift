import XCTest
@testable import DNSKit

final class TLSClientTests: XCTestCase, IClientTests {
    func testQuery() async throws {
        try await ClientTests(transportType: .TLS, serverAddress: "1.1.1.1:853").testQuery()
    }

    func testQueryNXDOMAIN() async throws {
        try await ClientTests(transportType: .TLS, serverAddress: "1.1.1.1:853").testQueryNXDOMAIN()
    }

    func testAuthenticateMessage() async throws {
        try await ClientTests(transportType: .TLS, serverAddress: "1.1.1.1:853").testAuthenticateMessage()
    }

    func testRandomData() async throws {
        try await ClientTests(transportType: .TLS, serverAddress: "127.0.0.1:8403").testRandomData()
    }

    func testLengthOver() async throws {
        try await ClientTests(transportType: .TLS, serverAddress: "127.0.0.1:8403").testLengthOver()
    }

    func testLengthUnder() async throws {
        try await ClientTests(transportType: .TLS, serverAddress: "127.0.0.1:8403").testLengthUnder()
    }
}
