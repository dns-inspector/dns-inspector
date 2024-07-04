import Foundation

/// Describes the record data for a TXT record
public struct TXTRecordData: RecordData {
    /// The record text
    public let text: String

    internal init(recordData: Data) throws {
        // TXT RDATA format is a collection of one or more strings, which are: length (uint8) + data
        // No encoding is defined, so we'll assumt UTF-8 and throw caution to the wind.

        var recordText = String()
        var moreToRead = true
        var offset = Int(0)

        while moreToRead {
            let length = recordData.withUnsafeBytes {
                return $0.loadUnaligned(fromByteOffset: offset, as: UInt8.self)
            }
            if length == 0 {
                moreToRead = false
                break
            }
            if offset+Int(length) > recordData.count {
                throw Utils.MakeError("Invalid length value in TXT RDATA")
            }

            offset += 1
            let data = recordData.subdata(in: offset..<offset+Int(length))
            let text = String(decoding: data, as: UTF8.self)

            recordText.append(text)
            offset += Int(length)

            if (recordData.count - 1) <= offset {
                moreToRead = false
            }
        }

        self.text = recordText
    }

    public var description: String {
        return self.text
    }
}
