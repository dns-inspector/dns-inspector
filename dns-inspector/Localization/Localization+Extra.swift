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

public extension RecordType {
    // swiftlint:disable cyclomatic_complexity
    @MainActor func recordDescription() -> String {
        switch self {
        case .A:
            return Localize.recorddescriptiona()
        case .NS:
            return Localize.recorddescriptionns()
        case .CNAME:
            return Localize.recorddescriptioncname()
        case .SOA:
            return Localize.recorddescriptionsoa()
        case .AAAA:
            return Localize.recorddescriptionaaaa()
        case .LOC:
            return Localize.recorddescriptionloc()
        case .SRV:
            return Localize.recorddescriptionsrv()
        case .TXT:
            return Localize.recorddescriptiontxt()
        case .MX:
            return Localize.recorddescriptionmx()
        case .PTR:
            return Localize.recorddescriptionptr()
        case .DS:
            return Localize.recorddescriptionds()
        case .RRSIG:
            return ""
        case .DNSKEY:
            return Localize.recorddescriptiondnskey()
        case .HTTPS:
            return Localize.recorddescriptionhttps()
        case .NSEC:
            return Localize.recorddescriptionnsec()
        case .NSEC3:
            return Localize.recorddescriptionnsec3()
        case .CAA:
            return Localize.recorddescriptioncaa()
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
