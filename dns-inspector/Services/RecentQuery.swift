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
    public let transportType: TransportType
    public let serverAddress: String
    public var id = UUID()

    enum CodingKeys: CodingKey {
        case recordType, name, transportType, serverAddress
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.recordType == rhs.recordType && lhs.name == rhs.name && lhs.transportType == rhs.transportType && lhs.serverAddress == rhs.serverAddress
    }
}

@MainActor
public class RecentQueryManager {
    static let shared = RecentQueryManager()
    public var queries: [RecentQuery]
    private static let recentPath = IO.fileInDocumentsDirectory("recent_queries.json")

    fileprivate init() {
        if !UserOptions.rememberQueries {
            self.queries = []
            return
        }

        if !IO.fileExists(RecentQueryManager.recentPath) {
            self.queries = []
            return
        }

        do {
            let data = try IO.read(RecentQueryManager.recentPath)
            self.queries = try JSONDecoder().decode([RecentQuery].self, from: data)
        } catch {
            self.queries = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(self.queries)
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
