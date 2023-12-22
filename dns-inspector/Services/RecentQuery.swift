import Foundation
import DNSKit

public struct RecentQuery: Codable, Identifiable, Equatable {
    public let recordType: UInt
    public let name: String
    public let clientType: UInt
    public let serverAddress: String
    public var id = UUID()

    enum CodingKeys: CodingKey {
        case recordType, name, clientType, serverAddress
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.recordType == rhs.recordType && lhs.name == rhs.name && lhs.clientType == rhs.clientType && lhs.serverAddress == rhs.serverAddress
    }

    public func recordTypeName() -> String {
        return RecordType.fromDNSKit(DNSRecordType(rawValue: self.recordType)!).name
    }

    public func clientTypeName() -> String {
        return ClientType.fromDNSKit(DNSClientType(rawValue: self.clientType)!).name
    }
}

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

        for (idx, query) in self.queries.enumerated() {
            if query == recentQuery {
                self.queries.remove(at: idx)
                self.queries.insert(recentQuery, at: 0)
                self.save()
                return
            }
        }

        if self.queries.count >= 5 {
            self.queries.remove(at: 4)
        }
        self.queries.insert(recentQuery, at: 0)
        self.save()
    }

    public func delete(_ at: IndexSet) {
        self.queries.remove(atOffsets: at)
        self.save()
    }
}
