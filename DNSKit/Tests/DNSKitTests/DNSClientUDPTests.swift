import XCTest
@testable import DNSKit

final class DNSClientUDPTests: XCTestCase, IClientTests {
    func testQuery() async throws {
        try await ClientTests(transportType: .DNS, serverAddress: "1.1.1.1:53").testQuery()
    }

    func testQueryNXDOMAIN() async throws {
        try await ClientTests(transportType: .DNS, serverAddress: "1.1.1.1:53").testQueryNXDOMAIN()
    }

    func testAuthenticateMessage() async throws {
        try await ClientTests(transportType: .DNS, serverAddress: "1.1.1.1:53").testAuthenticateMessage()
    }

    func testRandomData() async throws {
        try await ClientTests(transportType: .DNS, serverAddress: "127.0.0.1:8400").testRandomData()
    }

    func testLengthOver() async throws {
        // Test does not apply
    }

    func testLengthUnder() async throws {
        // Test does not apply
    }
}
