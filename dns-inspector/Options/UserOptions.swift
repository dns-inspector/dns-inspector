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

public enum TTLDisplayMode: Int, Sendable, Codable, Hashable, Identifiable {
    case relative = 0
    case absolute = 1

    public var id: Self { return self }
}

public enum BinaryDataDisplayMode: Int, Sendable, Codable, Hashable, Identifiable {
    case hex = 0
    case base64 = 1

    public var id: Self { return self }
}

@MainActor
private let defaultSavedServers: [DNSResolver] = [
    DNSResolver(name: "Cloudflare", type: .TLS, addresses: ["1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001"], id: UUID(uuidString: "18796193-dea5-4a92-b742-42a1b7481d65")!),
    DNSResolver(name: "Quad9", type: .DNS, addresses: ["9.9.9.9", "149.112.112.112", "2620:fe::fe", "2620:fe::9"], id: UUID(uuidString: "a10e153d-859c-4d3d-86fd-2791f13c96e4")!),
    DNSResolver(name: "Google", type: .HTTPS, addresses: ["dns.google/dns-query"], httpsBootstrapIps: ["8.8.8.8", "8.8.4.4", "2001:4860:4860::8888", "2001:4860:4860::8844"], id: UUID(uuidString: "3d5afcfb-e251-472b-90dc-a3dc4c2a36b7")!),
    DNSResolver(name: "DNS Inspector", type: .QUIC, addresses: ["20.47.87.112:853", "20.47.87.115:853", "[2603:1030:f02:3::3fd]:853", "[2603:1030:f02:3::430]:853"], id: UUID(uuidString: "ba689402-b08b-4f66-b8e6-e5a0ddd3ac12")!),
]

/// Schema history:
/// 2 - original releast
/// 3 - add "name" field to preset server
/// 4 - change preset server to DNSResolver, add DNS Inspector DoQ preset server, add limit for number of remembered queries
/// 5 - remove saved servers without any addresses and ensure there's always at least one server
private let currentSchemaVersion: Int = 5

private struct OptionsType: Codable {
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
    public var binaryDataDisplayMode: BinaryDataDisplayMode?

    public var savedServers: [DNSResolver]?
    public var lastUsedServer: DNSResolver?
}

@MainActor
public final class UserOptions {
    private static let optionsFilePath = IO.fileInDocumentsDirectory("options.json")
    private static var current = OptionsType(schemaVersion: currentSchemaVersion)

    // Have to disable this rule here as there's no real way to work around it - migration code is messy.
    // swiftlint:disable cyclomatic_complexity
    public static func load() {
        defer {
            UserOptions.save()
        }

        if !IO.fileExists(optionsFilePath) {
            return
        }

        let data: Data
        do {
            data = try IO.read(optionsFilePath)
        } catch {
            LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Error reading options file \(optionsFilePath): \(error)")
            return
        }

        // First read the settings file as a base JSON dictionary.
        // We're making the following assumptions about any future changes with this file:
        // 1. The top level of this JSON file is always an object
        // 2. The schema version of that file will be represented by an int
        // 3. The schema version of that file will use the key "schemaVersion"
        var base: [String:Any]
        do {
            base = try JSONSerialization.jsonObject(with: data) as? [String:Any] ?? [:]
        } catch {
            LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Error decoding options file: \(error)")
            return
        }

        guard let currentVersion = base["schemaVersion"] as? Int else {
            LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Options file does not contain a schema")
            return
        }

        switch currentVersion {
        case currentSchemaVersion:
            let options: OptionsType
            do {
                options = try JSONDecoder().decode(OptionsType.self, from: data)
            } catch {
                print("Error decoding options file \(optionsFilePath): \(error)")
                return
            }

            current = options
        case 4:
            LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Migrating options from \(currentVersion) to \(currentSchemaVersion)")

            // Remove invalid preset servers (those without at least one server address)
            let options: OptionsType4
            do {
                options = try JSONDecoder().decode(OptionsType4.self, from: data)
            } catch {
                print("Error decoding options file \(optionsFilePath): \(error)")
                return
            }
            current = options.convertToOptions()
            save()
        case 3:
            LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Migrating options from \(currentVersion) to \(currentSchemaVersion)")

            // Add name to preset server
            let options: OptionsType3
            do {
                options = try JSONDecoder().decode(OptionsType3.self, from: data)
            } catch {
                print("Error decoding options file \(optionsFilePath): \(error)")
                return
            }
            current = options.convertToOptions()
            save()
        case 2:
            LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Migrating options from \(currentVersion) to \(currentSchemaVersion)")

            // Add name to preset server
            let options: OptionsType2
            do {
                options = try JSONDecoder().decode(OptionsType2.self, from: data)
            } catch {
                print("Error decoding options file \(optionsFilePath): \(error)")
                return
            }
            let options3 = options.convertToOptions()
            current = options3.convertToOptions()
            save()
        default:
            LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Schema of settings file is newer than what is supported by the app. \(currentVersion) > \(currentSchemaVersion)")
            return
        }

        LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Loaded options")
    }
    // swiftlint:enable cyclomatic_complexity

    public static func save() {
        let data: Data
        do {
            data = try JSONEncoder().encode(current)
        } catch {
            LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Error encoding options: \(error)")
            return
        }

        do {
            try IO.write(optionsFilePath, data: data)
        } catch {
            LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Error writing options file \(optionsFilePath): \(error)")
            return
        }

        LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Options saved")
    }

    public static var appLaunchCount: Int {
        get {
            return current.appLaunchCount ?? 0
        }
        set {
            current.appLaunchCount = newValue
            save()
        }
    }

    public static var didPromptForReview: Bool {
        get {
            return current.didPromptForReview ?? false
        }
        set {
            current.didPromptForReview = newValue
            save()
        }
    }

    public static var rememberQueries: Bool {
        get {
            return current.rememberQueries ?? true
        }
        set {
            current.rememberQueries = newValue
            save()
        }
    }

    public static var queryLimit: UInt8 {
        get {
            return current.queryLimit ?? 5
        }
        set {
            current.queryLimit = newValue
            save()
        }
    }

    public static var rememberLastServer: Bool {
        get {
            return current.rememberLastServer ?? true
        }
        set {
            current.rememberLastServer = newValue
            if !newValue {
                current.lastUsedServer = nil
            }
            save()
        }
    }

    public static var ttlDisplayMode: TTLDisplayMode {
        get {
            return current.ttlDisplayMode ?? .relative
        }
        set {
            current.ttlDisplayMode = newValue
            save()
        }
    }

    public static var showRecordDescription: Bool {
        get {
            return current.showRecordDescription ?? true
        }
        set {
            current.showRecordDescription = newValue
            save()
        }
    }

    public static var dnsPrefersTcp: Bool {
        get {
            return current.dnsPrefersTcp ?? true
        }
        set {
            current.dnsPrefersTcp = newValue
            save()
        }
    }

    public static var timeoutSeconds: UInt8 {
        get {
            return current.timeoutSeconds ?? 5
        }
        set {
            if newValue == 0 {
                return
            }

            current.timeoutSeconds = newValue
            save()
        }
    }

    public static var appLanguage: SupportedLanguages? {
        get {
            return current.appLanguage
        }
        set {
            if let newValue = newValue {
                currentLanguage = newValue
            }
            current.appLanguage = newValue
            save()
        }
    }

    public static var automaticDnssecValidation: Bool {
        get {
            return current.automaticDnssecValidation ?? false
        }
        set {
            current.automaticDnssecValidation = newValue
            save()
        }
    }

    public static var binaryDataDisplayMode: BinaryDataDisplayMode {
        get {
            return current.binaryDataDisplayMode ?? .base64
        }
        set {
            current.binaryDataDisplayMode = newValue
            save()
        }
    }

    public static var savedServers: [DNSResolver] {
        get {
            return current.savedServers ?? defaultSavedServers
        }
        set {
            current.savedServers = newValue
            save()
            NotificationCenter.default.post(name: presetServerChangedNotification, object: nil)
        }
    }

    public static var lastUsedServer: DNSResolver? {
        get {
            return current.lastUsedServer
        }
        set {
            current.lastUsedServer = newValue
            save()
        }
    }
}

// MARK: - 1 to 2

private struct PresetServer2: Codable, Identifiable {
    public let type: TransportType
    public let address: String
    public var id = UUID()

    enum CodingKeys: CodingKey {
        case type, address
    }
}

@MainActor
private struct LastUsedServer2: Codable {
    let transportType: TransportType
    let address: String
}

private struct OptionsType2: Codable {
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

// MARK: - 2 to 3

private struct PresetServer3: Codable, Identifiable {
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

private struct OptionsType3: Codable {
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

// MARK: - 3 to 4

private struct OptionsType4: Codable {
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
        if savedServers.count == 0 {
            savedServers.append(defaultSavedServers[0])
        }
        newOptions.savedServers = savedServers

        return newOptions
    }
}

private struct DNSResolver4: Codable, Identifiable, Equatable {
    public let name: String?
    public let type: TransportType
    public let addresses: [String]
    public let httpsBootstrapIps: [String]?
    public let useHttp2: Bool?
    public let id: UUID
}
