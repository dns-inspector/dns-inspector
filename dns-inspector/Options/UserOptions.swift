import Foundation
import DNSKit

public enum TTLDisplayMode: Int, Codable {
    case relative = 0
    case absolute = 1
}

fileprivate struct OptionsType: Codable {
    public var schemaVersion: Int
    public var rememberQueries: Bool?
    public var showTips: Bool?
    public var ttlDisplayMode: TTLDisplayMode?
    public var presetServers: [PresetServer]?
}

public class UserOptions {
    private static let optionsFilePath = IO.fileInDocumentsDirectory("options.json")
    private static var current = OptionsType(schemaVersion: 1)

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

        let options: OptionsType
        do {
            options = try JSONDecoder().decode(OptionsType.self, from: data)
        } catch {
            print("Error decoding options file \(optionsFilePath): \(error)")
            return
        }

        current = options
        print("Loaded options")
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

    public static var rememberQueries: Bool {
        get {
            return current.rememberQueries ?? true
        }
        set {
            current.rememberQueries = newValue
            save()
        }
    }

    public static var showTips: Bool {
        get {
            return current.showTips ?? true
        }
        set {
            current.showTips = newValue
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

    public static var presetServers: [PresetServer] {
        get {
            return current.presetServers ?? [
                PresetServer(type: DNSServerType.HTTPS.rawValue, address: "https://dns.google/dns-query")
            ]
        }
        set {
            current.presetServers = newValue
            save()
        }
    }
}
