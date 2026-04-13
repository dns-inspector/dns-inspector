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

internal struct OptionsType4: Codable {
    public var schemaVersion: Int
    public var appLaunchCount: Int?
    public var didPromptForReview: Bool?
    public var rememberQueries: Bool?
    public var queryLimit: UInt8?
    public var rememberLastServer: Bool?
    public var ttlDisplayMode: TTLDisplayMode?
    public var showRecordDescription: Bool?
    public var dnsPrefersTcp: Bool?
    public var timeoutSeconds: UInt8?
    public var appLanguage: SupportedLanguages?
    public var automaticDnssecValidation: Bool?

    public var savedServers: [DNSResolver4]?
    public var lastUsedServer: DNSResolver4?

    @MainActor public func convertToOptions() -> OptionsType {
        var newOptions = OptionsType(schemaVersion: 5)
        newOptions.schemaVersion = self.schemaVersion
        newOptions.appLaunchCount = self.appLaunchCount
        newOptions.didPromptForReview = self.didPromptForReview
        newOptions.rememberQueries = self.rememberQueries
        newOptions.queryLimit = self.queryLimit
        newOptions.rememberLastServer = self.rememberLastServer
        newOptions.ttlDisplayMode = self.ttlDisplayMode
        newOptions.showRecordDescription = self.showRecordDescription
        newOptions.dnsPrefersTcp = self.dnsPrefersTcp
        newOptions.timeoutSeconds = self.timeoutSeconds
        newOptions.appLanguage = self.appLanguage
        newOptions.automaticDnssecValidation = self.automaticDnssecValidation

        var savedServers: [DNSResolver] = []
        for savedServer in self.savedServers ?? [] where savedServer.addresses.isEmpty == false {
            savedServers.append(DNSResolver(name: savedServer.name, type: savedServer.type, addresses: savedServer.addresses, id: savedServer.id))
        }
        newOptions.savedServers = savedServers

        return newOptions
    }
}

internal struct DNSResolver4: Codable, Identifiable, Equatable {
    public let name: String?
    public let type: TransportType
    public let addresses: [String]
    public let httpsBootstrapIps: [String]?
    public let useHttp2: Bool?
    public let id: UUID
}
