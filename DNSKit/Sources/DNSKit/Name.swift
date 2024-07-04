import Foundation

/// Utilities for working with DNS names
public class Name {
    /// Encode a string as a DNS name. Will throw if an invalid DNS name is provided.
    /// - Parameter name: The DNS name to encode
    /// - Returns: A byte array containing the encoded name
    public static func stringToName(_ name: String) throws -> Data {
        if name.count == 1 && name == "." {
            return Data.zeroByte()
        }

        var buf = Data()

        // Note that we're not using the splitName function from this class
        // because the behaviour is different and undesired for this specific
        // use-case
        let labels = name.split(separator: ".")

        for label in labels {
            // Skip trailing '.'
            if label.count == 0 && label == labels.last {
                break
            }

            if label.count > 63 {
                throw Utils.MakeError("Invalid DNS name: individual label exceeds 63 characters")
            }

            let length = UInt8(label.count)
            withUnsafePointer(to: length) { l in
                buf.append(l, count: 1)
            }
            if label.count == 0 {
                continue
            }
            if let rawLabel = label.data(using: .ascii) {
                buf.append(rawLabel)
            }
        }

        // Add the terminator
        buf.appendZeroByte()
        return buf
    }

    /// Reads and decodes a DNS name from the given data, decompressing the name if needed. Will throw on invalid data.
    /// - Parameters:
    ///   - data: The data to read from, typically an entire DNS message
    ///   - startOffset: The offset to start reading the name from
    /// - Returns: A tuple of the DNS name and the offset of where to continue reading data after this name has ended.
    public static func readName(_ data: Data, startOffset: Int) throws -> (name: String, dataOffset: Int) {
        if startOffset < 0 || startOffset >= data.count {
            throw Utils.MakeError("Invalid start offset when reading DNS name")
        }

        return try data.withUnsafeBytes { buffer in
            if buffer[startOffset...startOffset].load(as: UInt8.self) == 0 {
                return (".", startOffset+1)
            }

            var offset = startOffset
            var dataOffset = 0
            var name = String()

            // DNS compression can apply to the entire name or individual lables, so check for pointers at each label
            while true {
                var pointerFlag = buffer[offset...offset].load(as: UInt8.self)
                if pointerFlag == 0 {
                    break
                }

                if (pointerFlag & (1 << 7)) != 0 {
                    // Label is a pointer
                    if dataOffset == 0 {
                        dataOffset = offset+2
                    }

                    var nextOffset = offset
                    var depth = 0

                    // Continue to follow pointers until we get to a length, up to a maximum depth of 10
                    while (pointerFlag & (1 << 7)) != 0 {
                        if depth > 10 {
                            throw Utils.MakeError("Maximum pointer depth reached")
                        }

                        nextOffset = Int(buffer[offset+1...offset+1].load(as: UInt8.self))
                        if nextOffset > data.count-1 {
                            throw Utils.MakeError("Pointer offset outside of data bounds")
                        }

                        pointerFlag = buffer[nextOffset...nextOffset].load(as: UInt8.self)
                        depth += 1
                    }

                    offset = nextOffset
                }

                let length = buffer[offset...offset].load(as: UInt8.self)
                offset += 1

                if offset+Int(length) > data.count-1 {
                    throw Utils.MakeError("Length or offset outside of data bounds")
                }

                guard let label = String(data: data[offset...offset+Int(length)-1], encoding: .ascii) else {
                    throw Utils.MakeError("Invalid data in label text")
                }
                offset += Int(length)

                if label.contains(".") {
                    throw Utils.MakeError("Illegal characters in label text")
                }

                name.append("\(label).")
            }

            if dataOffset == 0 {
                dataOffset = startOffset + name.count + 1
            }

            return (name, dataOffset)
        }
    }

    /// Split the given name into individual labels.
    /// - Parameter name: The DNS name. If only the root zone is passed ('.'), returns an empty array.
    /// - Returns: An array of labels
    public static func splitName(_ name: String) -> [String] {
        if name == "" {
            return []
        }
        if name.count == 1 && name == "." {
            return []
        }

        var n = NSString(string: name)
        if name.hasSuffix(".") {
            n = NSString(string: n.substring(to: n.length-1))
        }

        return n.components(separatedBy: ".")
    }
}
