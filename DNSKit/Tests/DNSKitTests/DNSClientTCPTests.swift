import XCTest
@testable import DNSKit

final class DNSClientTCPTests: XCTestCase, IClientTests {
    func testQuery() async throws {
        try await ClientTests(transportType: .DNS, transportOptions: TransportOptions(dnsPrefersTcp: true), serverAddress: "1.1.1.1:53").testQuery()
    }

    func testQueryNXDOMAIN() async throws {
        try await ClientTests(transportType: .DNS, transportOptions: TransportOptions(dnsPrefersTcp: true), serverAddress: "1.1.1.1:53").testQueryNXDOMAIN()
    }

    func testAuthenticateMessage() async throws {
        try await ClientTests(transportType: .DNS, transportOptions: TransportOptions(dnsPrefersTcp: true), serverAddress: "1.1.1.1:53").testAuthenticateMessage()
    }

    func testRandomData() async throws {
        try await ClientTests(transportType: .DNS, transportOptions: TransportOptions(dnsPrefersTcp: true), serverAddress: "127.0.0.1:8401").testRandomData()
    }

    func testLengthOver() async throws {
        try await ClientTests(transportType: .DNS, transportOptions: TransportOptions(dnsPrefersTcp: true), serverAddress: "127.0.0.1:8401").testLengthOver()
    }

    func testLengthUnder() async throws {
        try await ClientTests(transportType: .DNS, transportOptions: TransportOptions(dnsPrefersTcp: true), serverAddress: "127.0.0.1:8401").testLengthUnder()
    }
}
