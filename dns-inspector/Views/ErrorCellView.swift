import SwiftUI

public struct ErrorCellView: View {
    public let error: String
    public let titleKey: String

    public init(error: Error, titleKey: String = "Error") {
        self.error = error.localizedDescription
        self.titleKey = titleKey
    }

    public init(error: String, titleKey: String = "Error") {
        self.error = error
        self.titleKey = titleKey
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
                Text(localized: self.titleKey).bold()
            }
            Text(error)
        }
    }
}

#Preview {
    ErrorCellView(error: NSError(domain: "com.example", code: -1, userInfo: [NSLocalizedDescriptionKey: "Hello, world!"]))
}
