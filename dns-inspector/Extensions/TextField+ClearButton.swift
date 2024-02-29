import SwiftUI

struct ClearButton: View {
    @Binding var text: String

    var body: some View {
        if !text.isEmpty {
            Button {
                self.text = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondaryText)
            }
            .padding(.trailing, 8)
        }
    }
}
