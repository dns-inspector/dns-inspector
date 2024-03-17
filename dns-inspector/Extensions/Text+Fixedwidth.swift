import SwiftUI

extension Text {
    public func fixedwidth(_ size: CGFloat = 16, isActive: Bool = true) -> Text {
        return self.font(Font.custom("Menlo", size: size, relativeTo: .body))
    }
}
