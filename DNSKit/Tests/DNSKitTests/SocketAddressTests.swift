import XCTest
@testable import DNSKit

final class SocketAddressTests: XCTestCase {
    func testIPv4() throws {
        let address = try SocketAddress(addressString: "127.0.0.100")
        XCTAssertEqual(address.ipAddress, "127.0.0.100")
        XCTAssertNil(address.port)
        XCTAssertEqual(address.version, .v4)
    }

    func testInvalidIPv4() throws {
        do {
            _ = try SocketAddress(addressString: "256.0.0.1")
            XCTFail("No error seen when one expected")
        } catch {
            //
        }
    }

    func testIPv4WithPort() throws {
        let address = try SocketAddress(addressString: "127.0.0.1:80")
        XCTAssertEqual(address.ipAddress, "127.0.0.1")
        XCTAssertEqual(address.port, 80)
        XCTAssertEqual(address.version, .v4)
    }

    func testInvalidIPv4WithPort() throws {
        do {
            _ = try SocketAddress(addressString: "256.0.0.1:80")
            XCTFail("No error seen when one expected")
        } catch {
            //
        }
    }

    func testIPv4WithInvalidPort() throws {
        do {
            _ = try SocketAddress(addressString: "256.0.0.1:65536")
            XCTFail("No error seen when one expected")
        } catch {
            //
        }
    }

    func testIPv6() throws {
        let address = try SocketAddress(addressString: "fe80::1")
        XCTAssertEqual(address.ipAddress, "fe80::1")
        XCTAssertNil(address.port)
        XCTAssertEqual(address.version, .v6)
    }

    func testInvalidIPv6() throws {
        do {
            _ = try SocketAddress(addressString: "fffff::1")
            XCTFail("No error seen when one expected")
        } catch {
            //
        }
    }

    func testIPv6WithPort() throws {
        let address = try SocketAddress(addressString: "[fe80::1]:80")
        XCTAssertEqual(address.ipAddress, "fe80::1")
        XCTAssertEqual(address.port, 80)
        XCTAssertEqual(address.version, .v6)
    }

    func testInvalidIPv6WithPort() throws {
        do {
            _ = try SocketAddress(addressString: "[fe80:car::1]:80")
            XCTFail("No error seen when one expected")
        } catch {
            //
        }
    }

    func testIPv6WithInvalidPort() throws {
        do {
            _ = try SocketAddress(addressString: "[fe80::1]:65536")
            XCTFail("No error seen when one expected")
        } catch {
            //
        }
    }
}
