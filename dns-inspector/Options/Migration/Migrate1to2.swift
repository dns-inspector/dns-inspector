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

internal struct PresetServer2: Codable, Identifiable {
    public let type: TransportType
    public let address: String
    public var id = UUID()

    enum CodingKeys: CodingKey {
        case type, address
    }
}

@MainActor
internal struct LastUsedServer2: Codable {
    let transportType: TransportType
    let address: String
}

internal struct OptionsType2: Codable {
    public var schemaVersion: Int
    public var appLaunchCount: Int?
    public var didPromptForReview: Bool?
    public var rememberQueries: Bool?
    public var rememberLastServer: Bool?
    public var ttlDisplayMode: TTLDisplayMode?
    public var showRecordDescription: Bool?
    public var dnsPrefersTcp: Bool?
    public var timeoutSeconds: UInt8?
    public var appLanguage: SupportedLanguages?
    public var automaticDnssecValidation: Bool?

    public var presetServers: [PresetServer2]?
    public var lastUsedServer: LastUsedServer2?

    @MainActor public func convertToOptions() -> OptionsType3 {
        var newOptions = OptionsType3(schemaVersion: 3)
        newOptions.appLaunchCount = self.appLaunchCount
        newOptions.didPromptForReview = self.didPromptForReview
        newOptions.rememberQueries = self.rememberQueries
        newOptions.rememberLastServer = self.rememberLastServer
        newOptions.ttlDisplayMode = self.ttlDisplayMode
        newOptions.showRecordDescription = self.showRecordDescription
        newOptions.dnsPrefersTcp = self.dnsPrefersTcp
        newOptions.timeoutSeconds = 5
        newOptions.appLanguage = self.appLanguage
        newOptions.automaticDnssecValidation = self.automaticDnssecValidation
        newOptions.lastUsedServer = self.lastUsedServer

        if let presetServers = self.presetServers {
            newOptions.presetServers = []
            for presetServer in presetServers {
                let name: String
                if presetServer.type == .TLS && presetServer.address == "1.1.1.1" {
                    name = "Cloudflare"
                } else if presetServer.type == .DNS && presetServer.address == "9.9.9.9" {
                    name = "Quad9"
                } else if presetServer.type == .HTTPS && presetServer.address == "dns.google/dns-query" {
                    name = "Google"
                } else {
                    name = presetServer.address
                }
                newOptions.presetServers?.append(PresetServer3(name: name, type: presetServer.type, address: presetServer.address, id: presetServer.id))
            }
        }

        return newOptions
    }
}
