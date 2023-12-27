import SwiftUI

public struct ErrorCellView: View {
    public let error: Error

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
                Text(localized: "Error").bold()
            }
            Text(error.localizedDescription)
        }
    }
}

#Preview {
    ErrorCellView(error: NSError(domain: "com.example", code: -1, userInfo: [NSLocalizedDescriptionKey: "Hello, world!"]))
}
