// DNS Inspector
// Copyright (C) Ian Spence and other DNS Inspector Contributors
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

struct AppIconView: View {
    private let icons = ["Default", "Pride", "Trans"]

    var body: some View {
        List {
            Section {
                ForEach(icons, id: \.self) { iconName in
                    Button {
                        UIApplication.shared.setAlternateIconName("Icon\(iconName)")
                    } label: {
                        HStack {
                            Image("Preview\(iconName)")
                            Text(Localize("Icon\(iconName)"))
                        }
                    }
                }
            } footer: {
                Text(Localize("AppIconFooter"))
            }
        }.navigationTitle(Localize("App Icon"))
    }
}
