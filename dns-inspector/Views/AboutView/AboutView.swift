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
import DNSKit

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { frame in
            Navigation {
                VStack {
                    VStack {
                        Image(systemName: "link.circle.fill")
                            .resizable(resizingMode: .stretch)
                            .foregroundColor(Color.white)
                            .frame(width: 75.0, height: 75.0)
                        Text(localized: "DNS Inspector")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: frame.size.height*0.40)
                    .background(.linearGradient(.init(colors: [Color("Gradient1", bundle: nil), Color("Gradient2", bundle: nil)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    AboutTableViewRepresentable()
                }
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "xmark")
                        })
                        .tint(.white)
                    }
                }
                .background(Color(uiColor: UIColor.systemGroupedBackground))
            }
        }
    }
}
