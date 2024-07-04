import XCTest
@testable import DNSKit

final class QueryTests: XCTestCase {
    func testValidateDNSClientConfigurationValidDNS() throws {
        XCTAssertNil(Query.validateConfiguration(transportType: .DNS, serverAddress: "8.8.8.8"))
    }

    func testValidateDNSClientConfigurationValidDOT() throws {
        XCTAssertNil(Query.validateConfiguration(transportType: .TLS, serverAddress: "8.8.8.8:853"))
    }

    func testValidateDNSClientConfigurationValidDOH() throws {
        XCTAssertNil(Query.validateConfiguration(transportType: .HTTPS, serverAddress: "https://dns.google/dns-query"))
    }

    func testValidateDNSClientConfigurationInvalidDNS() throws {
        XCTAssertNotNil(Query.validateConfiguration(transportType: .DNS, serverAddress: "8.8.8.8.8"))
    }

    func testValidateDNSClientConfigurationInvalidDOT() throws {
        XCTAssertNotNil(Query.validateConfiguration(transportType: .TLS, serverAddress: "8.8.8.8:65536"))
    }

    func testValidateDNSClientConfigurationInvalidDOH() throws {
        XCTAssertNotNil(Query.validateConfiguration(transportType: .HTTPS, serverAddress: "http://dns.google/dns-query"))
    }
}
