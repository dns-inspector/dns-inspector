import SwiftUI

public extension Text {
    init(localized: String) {
        self.init(verbatim: Localize(localized))
    }

    init(localized: String, args: [String]) {
        self.init(verbatim: Localize(localized, args: args))
    }
}

public extension View {
    func navigationTitle(localized: String) -> some View {
        return self.navigationTitle(Text(localized: localized))
    }

    func navigationTitle(localized: String, args: [String]) -> some View {
        return self.navigationTitle(Text(localized: localized, args: args))
    }
}
