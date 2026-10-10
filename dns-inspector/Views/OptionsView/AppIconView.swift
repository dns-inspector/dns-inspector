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
    private let icons = ["Default", "Liquid", "Pride", "Trans"]
    @State private var isLoading = false
    @State private var showError = false
    @State private var setError: Error?

    var body: some View {
        List {
            Section {
                ForEach(icons, id: \.self) { iconName in
                    Button {
                        Task {
                            await self.changeIcon(to: iconName == "Default" ? nil : "Icon\(iconName)")
                        }
                    } label: {
                        HStack {
                            Image("Preview\(iconName)")
                            Text(localizedIconName(iconName))
                        }
                    }.disabled(isLoading)
                }
            } footer: {
                Text(Localize.appiconfooter())
            }
            .alert("Unable to Set Alternate Icon", item: $setError) { _ in
                Button("Dismiss") {
                    setError = nil
                }
            } message: { error in
                Text("\(error.localizedDescription)")
            }

        }.navigationTitle(Localize.appicon())
    }

    func localizedIconName(_ iconName: String) -> String {
        switch iconName {
        case "Default":
            return Localize.icondefault()
        case "Liquid":
            return "Liquid"
        case "Pride":
            return Localize.iconpride()
        case "Trans":
            return Localize.icontrans()
        default:
            return ""
        }
    }

    func changeIcon(to icon: String?) async {
        self.isLoading = true
        defer {
            self.isLoading = false
        }

        guard let icon else {
            print("Restoring default icon")
            do {
                try await UIApplication.shared.setAlternateIconName(nil)
            } catch {
                print("Failed to set icon \(error)")
                self.setError = error
            }
            return
        }

        do {
            print("Attempting to set alternate icon to \(icon)")

            guard UIApplication.shared.alternateIconName != icon else {
                print("Alternate icon name is already \(icon)")
                return
            }
            guard let bundleIcons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any] else {
                print("No bundle icons")
                return
            }
            guard let alternateIcons = bundleIcons["CFBundleAlternateIcons"] as? [String: Any] else {
                print("No alternate icons")
                return
            }
            if alternateIcons[icon] == nil {
                print("No alternate icon with name \(icon)")
                return
            }

            try await UIApplication.shared.setAlternateIconName(icon)
            print("Did set")
        } catch {
            print("Failed to set icon \(error)")
            self.setError = error
        }
    }
}
