import SwiftUI

struct RoundedLabel: View {
    let text: String
    let color: Color

    init(text: String) {
        self.text = text
        self.color = .accent
    }

    init(text: String, color: Color) {
        self.text = text
        self.color = color
    }

    var body: some View {
        VStack {
            Text(self.text)
                .padding(.horizontal, 10.0)
                .padding(.vertical, 2.0)
                .foregroundStyle(self.color)
        }
        .cornerRadius(5.0)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(self.color, lineWidth: 1)
        )
    }
}
