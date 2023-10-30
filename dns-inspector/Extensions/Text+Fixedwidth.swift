import SwiftUI

extension Text {
    public func fixedwidth(_ isActive: Bool = true) -> Text {
        return self.font(Font.custom("Menlo", size: 16, relativeTo: .body))
    }
}
