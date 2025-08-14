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

public struct RecentQuery: Codable, Identifiable, Equatable {
    public let recordType: RecordType
    public let name: String
    public let resolver: DNSResolver
    public var id = UUID()

    enum CodingKeys: CodingKey {
        case recordType, name, resolver
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.recordType == rhs.recordType && lhs.name == rhs.name && lhs.resolver == rhs.resolver
    }
}

// Schema history:
//   - Initial release did not have a schema version
// 2 - add DNSResolver type to query
private let currentSchemaVersion: Int = 4

private struct RecentQueryStoreType: Codable {
    let schemaVersion: Int
    let queries: [RecentQuery]
}

@MainActor
private struct RecentQuery1: Codable {
    let recordType: RecordType
    let name: String
    let transportType: TransportType
    let serverAddress: String

    func update() -> RecentQuery {
        return RecentQuery(recordType: self.recordType, name: self.name, resolver: DNSResolver(type: self.transportType, address: self.serverAddress, id: UUID()))
    }
}

@MainActor
public class RecentQueryManager {
    static let shared = RecentQueryManager()
    public private(set) var queries: [RecentQuery]
    private static let recentPath = IO.fileInDocumentsDirectory("recent_queries.json")

    fileprivate init() {
        if !UserOptions.rememberQueries {
            self.queries = []
            return
        }

        if !IO.fileExists(RecentQueryManager.recentPath) {
            LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Recent query file does not exist")
            self.queries = []
            return
        }

        let data: Data
        do {
            data = try IO.read(RecentQueryManager.recentPath)
        } catch {
            LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Error reading recent query file: \(error)")
            self.queries = []
            return
        }

        // Try to decode it using the legacy structure
        // Remove after 2026-01-01
        do {
            let oldQueries = try JSONDecoder().decode([RecentQuery1].self, from: data)
            LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Migrating recent query file from initial schema version")
            self.queries = []
            for oldQuery in oldQueries {
                self.queries.append(oldQuery.update())
            }
            return
        } catch {
            // Pass, it's fine
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
            LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Error decoding recent queries file: \(error)")
            self.queries = []
            return
        }

        guard let currentVersion = base["schemaVersion"] as? Int else {
            LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Recent queries file does not contain a schema version")
            self.queries = []
            return
        }

        if currentVersion > currentSchemaVersion {
            LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Schema of settings file is newer than what is supported by the app. \(currentVersion) > \(currentSchemaVersion)")
            self.queries = []
            return
        } else if currentVersion == currentSchemaVersion {
            do {
                let stored = try JSONDecoder().decode(RecentQueryStoreType.self, from: data)
                self.queries = stored.queries
                LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Loaded recent queries")
            } catch {
                print("Error decoding recent queries file \(RecentQueryManager.recentPath): \(error)")
                self.queries = []
                return
            }
        } else {
            // Reserved for later migrations
            self.queries = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(RecentQueryStoreType(schemaVersion: currentSchemaVersion, queries: self.queries))
            try IO.write(RecentQueryManager.recentPath, data: data)
        } catch {
            //
        }
    }

    public func purge() {
        do {
            try IO.delete(RecentQueryManager.recentPath)
        } catch {
            //
        }
    }

    public func add(_ recentQuery: RecentQuery) {
        if !UserOptions.rememberQueries {
            self.queries = []
            return
        }

        for (idx, query) in self.queries.enumerated() where query == recentQuery {
            self.queries.remove(at: idx)
            self.queries.insert(recentQuery, at: 0)
            self.save()
            return
        }

        while self.queries.count >= UserOptions.queryLimit {
            self.queries.removeLast()
        }
        self.queries.insert(recentQuery, at: 0)
        self.save()
    }

    public func delete(_ at: IndexSet) {
        self.queries.remove(atOffsets: at)
        self.save()
    }
}
