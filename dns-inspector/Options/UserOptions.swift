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

@MainActor
public enum TTLDisplayMode: Int, Codable {
    case relative = 0
    case absolute = 1
}

@MainActor
public struct LastUsedServer: Codable {
    let transportType: TransportType
    let address: String
}

/// Schema history:
/// 2 - original releast
/// 3 - add "name" field to preset server
/// 4 - add DNS Inspector DoQ preset server
private let currentSchemaVersion: Int = 4

private struct OptionsType: Codable {
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

    public var presetServers: [PresetServer]?
    public var lastUsedServer: LastUsedServer?
}

@MainActor
public final class UserOptions {
    private static let optionsFilePath = IO.fileInDocumentsDirectory("options.json")
    private static var current = OptionsType(schemaVersion: currentSchemaVersion)

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

        if currentVersion > currentSchemaVersion {
            LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Schema of settings file is newer than what is supported by the app. \(currentVersion) > \(currentSchemaVersion)")
            return
        } else if currentVersion == currentSchemaVersion {
            let options: OptionsType
            do {
                options = try JSONDecoder().decode(OptionsType.self, from: data)
            } catch {
                print("Error decoding options file \(optionsFilePath): \(error)")
                return
            }

            current = options
        } else if currentVersion == 3 {
            LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Migrating options")

            var options: OptionsType
            do {
                options = try JSONDecoder().decode(OptionsType.self, from: data)
            } catch {
                print("Error decoding options file \(optionsFilePath): \(error)")
                return
            }

            if options.presetServers?.contains(where: { server in
                return server.type == .QUIC && server.address == "20.47.87.112:853"
            }) == nil {
                options.presetServers?.append(PresetServer(name: "DNS Inspector", type: .QUIC, address: "20.47.87.112:853"))
            }

            current = options
            current.schemaVersion = 4
        } else if currentVersion == 2 {
            LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Migrating options")

            // Add name to preset server
            let options: OptionsType2
            do {
                options = try JSONDecoder().decode(OptionsType2.self, from: data)
            } catch {
                print("Error decoding options file \(optionsFilePath): \(error)")
                return
            }
            current = options.convertToOptions()
        }

        LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Loaded options")
    }

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

    public static var presetServers: [PresetServer] {
        get {
            return current.presetServers ?? [
                PresetServer(name: "Cloudflare", type: .TLS, address: "1.1.1.1"),
                PresetServer(name: "Quad9", type: .DNS, address: "9.9.9.9"),
                PresetServer(name: "Google", type: .HTTPS, address: "dns.google/dns-query"),
                PresetServer(name: "DNS Inspector", type: .QUIC, address: "20.47.87.112:853"),
            ]
        }
        set {
            current.presetServers = newValue
            save()
            NotificationCenter.default.post(name: presetServerChangedNotification, object: nil)
        }
    }

    public static var lastUsedServer: LastUsedServer? {
        get {
            return current.lastUsedServer
        }
        set {
            current.lastUsedServer = newValue
            save()
        }
    }
}

private struct PresetServer2: Codable, Identifiable {
    public let type: TransportType
    public let address: String
    public var id = UUID()

    enum CodingKeys: CodingKey {
        case type, address
    }
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
    public var lastUsedServer: LastUsedServer?

    public func convertToOptions() -> OptionsType {
        var newOptions = OptionsType(schemaVersion: currentSchemaVersion)
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
                newOptions.presetServers?.append(PresetServer(name: name, type: presetServer.type, address: presetServer.address, id: presetServer.id))
            }
        }

        return newOptions
    }
}
