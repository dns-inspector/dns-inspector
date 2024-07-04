import XCTest
@testable import DNSKit

final class WHOISTests: XCTestCase {
    func getLookupHostForDomain(_ input: String, expectedServer: String, expectedBare: String) {
        let (actualServer, actualBare) = WHOIS.getLookupHost(for: input)

        XCTAssertNotNil(actualServer)
        XCTAssertNotNil(actualBare)
        XCTAssertEqual(expectedServer, actualServer)
        XCTAssertEqual(expectedBare, actualBare)
    }

    func testGetLookupHostForDomain() {
        getLookupHostForDomain("example.com", expectedServer: "whois.verisign-grs.com", expectedBare: "example.com")
        getLookupHostForDomain("example.example.example.com", expectedServer: "whois.verisign-grs.com", expectedBare: "example.com")
        getLookupHostForDomain("example.cn.com", expectedServer: "whois.centralnic.net", expectedBare: "example.cn.com")
        getLookupHostForDomain("example.app", expectedServer: "whois.nic.app", expectedBare: "example.app")
        getLookupHostForDomain("example.example.example.app", expectedServer: "whois.nic.app", expectedBare: "example.app")

        // lmao please im begging you somebody register acab as a gtld
        let (server, bare) = WHOIS.getLookupHost(for: "blm.acab")
        XCTAssertNil(server)
        XCTAssertNil(bare)
    }

    func testWHOISLookup() async throws {
        let result = try await WHOIS.lookup("example.com")
        XCTAssertTrue(result.count > 0)
    }
}
