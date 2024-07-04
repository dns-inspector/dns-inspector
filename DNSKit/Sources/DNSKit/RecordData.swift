import Foundation

/// Describes a base protocol that all record-type specific structs must implement
public protocol RecordData {
    /// A textual representation of the record data. This is typically the same format as seen in the `dig` command-line tool.
    var description: String { get }
}
