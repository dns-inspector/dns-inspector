import SwiftUI

struct RoundedLabel: View {
    let text: String
    let textColor: Color
    let borderColor: Color

    init(text: String) {
        self.text = text
        self.textColor = .accent
        self.borderColor = .accent
    }

    init(text: String, color: Color) {
        self.text = text
        self.textColor = color
        self.borderColor = color
    }

    init(text: String, textColor: Color, borderColor: Color) {
        self.text = text
        self.textColor = textColor
        self.borderColor = borderColor
    }

    var body: some View {
        VStack {
            Text(self.text)
                .padding(.horizontal, 10.0)
                .padding(.vertical, 2.0)
                .foregroundStyle(self.textColor)
        }
        .cornerRadius(5.0)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(self.borderColor, lineWidth: 1)
        )
    }
}
