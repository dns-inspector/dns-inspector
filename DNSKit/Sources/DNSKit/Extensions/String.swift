import Foundation

internal extension String {
    subscript(_ idx: Int) -> Character {
        self[self.index(self.startIndex, offsetBy: idx)]
    }

    func substring(with: NSRange) -> String {
        let start = self.index(self.startIndex, offsetBy: with.location)
        let end = self.index(self.startIndex, offsetBy: with.location+with.length)

        return String(self[start..<end])
    }
}
