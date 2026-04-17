// DNS Inspector
// Copyright (C) Ian Spence and other DNS Inspector Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import DNSKit

internal extension TransportType {
    @MainActor func localized() -> String {
        switch self {
        case .DNS:
            Localize.traditionaldns()
        case .TLS:
            Localize.dnsovertls()
        case .HTTPS:
            Localize.dnsoverhttps()
        case .QUIC:
            Localize.dnsoverquic()
        case .System:
            Localize.systemdns()
        }
    }

    @MainActor func localizedTargetType() -> String {
        switch self {
        case .DNS, .TLS, .QUIC, .System:
            return Localize.serverip()
        case .HTTPS:
            return Localize.serverurl()
        }
    }

    @MainActor func placeholder() -> String {
        switch self {
        case .DNS, .TLS, .QUIC, .System:
            return "192.0.2.1"
        case .HTTPS:
            return "https://example.com/dns-query"
        }
    }
}
