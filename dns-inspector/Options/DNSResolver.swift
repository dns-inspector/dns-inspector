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

/// Describes a DNS Resolver (DNS server)
@MainActor
public struct DNSResolver: Codable, Identifiable, Equatable {
    /// The name of the DNS resolver, only used for saved (preset) servers.
    public let name: String?
    /// The transport type used for this DNS resolver.
    public let type: TransportType
    /// Addresses of the resolver. For DNS over HTTPS this is a single URL, otherwise it's multiple IP address.
    public let addresses: [String]
    /// The bootstrap IP address for DNS over HTTPS resolvers.
    public let httpsBootstrapIps: [String]?
    /// The ID of this resolver.
    public let id: UUID

    public init(name: String? = nil, type: TransportType, addresses: [String], httpsBootstrapIps: [String]? = nil, id: UUID) {
        self.name = name
        self.type = type
        self.addresses = addresses
        self.httpsBootstrapIps = httpsBootstrapIps
        self.id = id
    }
}
