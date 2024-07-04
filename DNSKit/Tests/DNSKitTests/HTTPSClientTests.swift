import XCTest
@testable import DNSKit

final class HTTPSClientTests: XCTestCase, IClientTests {
    func testQuery() async throws {
        try await ClientTests(transportType: .HTTPS, serverAddress: "https://dns.google/dns-query").testQuery()
    }

    func testQueryNXDOMAIN() async throws {
        try await ClientTests(transportType: .HTTPS, serverAddress: "https://dns.google/dns-query").testQueryNXDOMAIN()
    }

    func testAuthenticateMessage() async throws {
        try await ClientTests(transportType: .HTTPS, serverAddress: "https://dns.google/dns-query").testAuthenticateMessage()
    }

    func testRandomData() async throws {
        try await ClientTests(transportType: .HTTPS, serverAddress: "https://localhost:8402/dns-query").testRandomData()
    }

    func testLengthOver() async throws {
        // Test does not apply
    }

    func testLengthUnder() async throws {
        // Test does not apply
    }
}
