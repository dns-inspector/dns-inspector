// DNS Inspector
// Copyright (C) 2024 Ian Spence
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
