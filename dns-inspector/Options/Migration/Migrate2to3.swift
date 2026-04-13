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

internal struct PresetServer3: Codable, Identifiable {
    public let name: String
    public let type: TransportType
    public let address: String
    public var id = UUID()

    public init(name: String, type: TransportType, address: String, id: UUID = UUID()) {
        self.name = name
        self.type = type
        self.address = address
        self.id = id
    }

    enum CodingKeys: CodingKey {
        case name, type, address
    }
}

internal struct OptionsType3: Codable {
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

    public var presetServers: [PresetServer3]?
    public var lastUsedServer: LastUsedServer2?

    @MainActor public func convertToOptions() -> OptionsType {
        var newOptions = OptionsType(schemaVersion: 4)
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
        newOptions.lastUsedServer = nil

        var savedServers: [DNSResolver] = []
        for presetServer in self.presetServers ?? [] {
            let httpsBootstrapIps: [String]?
            if presetServer.type == .HTTPS && presetServer.address == "dns.google/dns-query" {
                httpsBootstrapIps = ["8.8.8.8", "8.8.4.4", "2001:4860:4860::8888", "2001:4860:4860::8844"]
            } else {
                httpsBootstrapIps = nil
            }
            savedServers.append(DNSResolver(name: presetServer.name, type: presetServer.type, addresses: [presetServer.address], httpsBootstrapIps: httpsBootstrapIps, id: presetServer.id))
        }
        savedServers.append(DNSResolver(name: "DNS Inspector", type: .QUIC, addresses: ["20.47.87.112:853", "20.47.87.115:853", "[2603:1030:f02:3::3fd]:853", "[2603:1030:f02:3::430]:853"], id: UUID(uuidString: "ba689402-b08b-4f66-b8e6-e5a0ddd3ac12")!))
        newOptions.savedServers = savedServers

        return newOptions
    }
}
