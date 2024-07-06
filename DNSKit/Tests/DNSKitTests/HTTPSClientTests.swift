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

    func testLocalRandomData() async throws {
        try await ClientTests(transportType: .HTTPS, serverAddress: "https://localhost:8402/dns-query").testLocalRandomData()
    }

    func testLocalLengthOver() async throws {
        // Test does not apply
    }

    func testLocalLengthUnder() async throws {
        // Test does not apply
    }

    func testLocalAQueryInvalidAddress() async throws {
        try await ClientTests(transportType: .HTTPS, serverAddress: "https://localhost:8402/dns-query").testLocalAQueryInvalidAddress()
    }
}
