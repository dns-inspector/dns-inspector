// DNS Inspector
// Copyright (C) 2024 Ian Spence
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

public enum TTLDisplayMode: Int, Codable {
    case relative = 0
    case absolute = 1
}

public struct LastUsedServer: Codable {
    let transportType: TransportType
    let address: String
}

private let currentSchemaVersion: Int = 2

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
        } else if currentVersion == 1 {
            // Migration from Obj-C to Swift in DNSKit
            let options: OptionsType1
            do {
                options = try JSONDecoder().decode(OptionsType1.self, from: data)
            } catch {
                print("Error decoding options file \(optionsFilePath): \(error)")
                return
            }
            current = options.convertToOptions2()
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
                PresetServer(type: .TLS, address: "1.1.1.1"),
                PresetServer(type: .DNS, address: "9.9.9.9"),
                PresetServer(type: .HTTPS, address: "dns.google/dns-query")
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

private struct OptionsType1: Codable {
    public var schemaVersion: Int
    public var appLaunchCount: Int?
    public var didPromptForReview: Bool?
    public var rememberQueries: Bool?
    public var rememberLastServer: Bool?
    public var ttlDisplayMode: TTLDisplayMode?
    public var showRecordDescription: Bool?
    public var dnsPrefersTcp: Bool?
    public var appLanguage: SupportedLanguages?
    public var enableDnssec: Bool?
    public var automaticDnssecValidation: Bool?

    public var presetServers: [PresetServer1]?
    public var lastUsedServer: LastUsedServer1?

    public func convertToOptions2() -> OptionsType {
        var newOptions = OptionsType(schemaVersion: currentSchemaVersion)
        newOptions.schemaVersion = self.schemaVersion
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

        if let oldPresetServers = self.presetServers {
            var newPresetServers: [PresetServer] = []
            for presetServer in oldPresetServers {
                guard let transportType = presetServer.transportType() else {
                    continue
                }

                newPresetServers.append(PresetServer(type: transportType, address: presetServer.address))
            }
            newOptions.presetServers = newPresetServers
        }

        if let lastUsedServer = self.lastUsedServer {
            if let transportType = lastUsedServer.clientType.transportType() {
                newOptions.lastUsedServer = LastUsedServer(transportType: transportType, address: lastUsedServer.address)
            }
        }
        return newOptions
    }
}

private struct PresetServer1: Codable {
    public let type: UInt
    public let address: String

    enum CodingKeys: CodingKey {
        case type, address
    }

    public func transportType() -> TransportType? {
        switch self.type {
        case 1:
            return .DNS
        case 2:
            return .HTTPS
        case 3:
            return .TLS
        default:
            return nil
        }
    }
}

private struct LastUsedServer1: Codable {
    let clientType: ClientType1
    let address: String
}

private struct ClientType1: Codable {
    public let name: String
    public let dnsKitValue: UInt
    public let id: UUID

    public func transportType() -> TransportType? {
        switch self.dnsKitValue {
        case 1:
            return .DNS
        case 2:
            return .HTTPS
        case 3:
            return .TLS
        default:
            return nil
        }
    }
}
