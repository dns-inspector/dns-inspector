import Foundation
import DNSKit

public enum TTLDisplayMode: Int, Codable {
    case relative = 0
    case absolute = 1
}

public struct LastUsedServer: Codable {
    let clientType: ClientType
    let address: String
}

private let currentSchemaVersion: Int = 1

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

    public var presetServers: [PresetServer]?
    public var lastUsedServer: LastUsedServer?
}

public class UserOptions {
    private static let optionsFilePath = IO.fileInDocumentsDirectory("options.json")
    private static var current = OptionsType1(schemaVersion: currentSchemaVersion)

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
            print("Error reading options file \(optionsFilePath): \(error)")
            return
        }

        // First read the settings file as a base JSON dictionary.
        // We're making the following assumptions about any future changes with this file:
        // 1. The top level of this JSON file is always an object
        // 2. The schema version of that file will be represented by an int
        // 3. The schema version of that file will use the key "schemaVersion"
        let base: [String:Any]
        do {
            base = try JSONSerialization.jsonObject(with: data) as? [String:Any] ?? [:]
        } catch {
            print("Error decoding options file \(optionsFilePath): \(error)")
            return
        }

        if let currentVersion = base["schemaVersion"] as? Int {
            if currentVersion > currentSchemaVersion {
                print("Schema of settings file is newer than what is supported by the app. \(currentVersion) > \(currentSchemaVersion)")
                return
            }
            if currentVersion < currentSchemaVersion {
                // Reserved for future use
                print("Need to migrate settings file to newer schema")
                return
            }

            let options: OptionsType1
            do {
                options = try JSONDecoder().decode(OptionsType1.self, from: data)
            } catch {
                print("Error decoding options file \(optionsFilePath): \(error)")
                return
            }

            current = options
            print("Loaded options")
        }
    }

    public static func save() {
        let data: Data
        do {
            data = try JSONEncoder().encode(current)
        } catch {
            print("Error encoding options: \(error)")
            return
        }

        do {
            try IO.write(optionsFilePath, data: data)
        } catch {
            print("Error writing options file \(optionsFilePath): \(error)")
            return
        }

        print("Options saved")
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

    public static var appLanguage: SupportedLanguages? {
        get {
            return current.appLanguage
        }
        set {
            current.appLanguage = newValue
            save()
        }
    }

    public static var presetServers: [PresetServer] {
        get {
            return current.presetServers ?? [
                PresetServer(type: DNSClientType.TLS.rawValue, address: "1.1.1.1"),
                PresetServer(type: DNSClientType.DNS.rawValue, address: "9.9.9.9"),
                PresetServer(type: DNSClientType.HTTPS.rawValue, address: "dns.google/dns-query")
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
