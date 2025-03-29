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

struct AppLanguageView: View {
    @State private var currentLanguage = UserOptions.appLanguage ?? .English
    @State private var showRestartAlert = false

    var body: some View {
        List {
            Section {
                ForEach(SupportedLanguages.allCases, id:\.rawValue) { language in
                    Button {
                        currentLanguage = language
                    } label: {
                        HStack {
                            Text(language.name)
                            Spacer()
                            if currentLanguage == language {
                                Image(systemName: "checkmark").foregroundStyle(.accent)
                            }
                        }
                    }.buttonStyle(.plain)
                }
            } footer: {
                // This is intentionally not localized
                Text("Spanish translation by Kevin López Brante. German translation by ErminesRoper. Interested in translating DNS Inspector to another language? Send us a message through the feedback link!")
            }
        }
        .navigationTitle(localized: "App language")
        .onChange(of: currentLanguage) { newLanguage in
            if newLanguage != UserOptions.appLanguage {
                UserOptions.appLanguage = newLanguage
                showRestartAlert = true
            }
        }
        .alert(Localize("App language"), isPresented: $showRestartAlert) {
            Button {
                showRestartAlert = false
            } label: {
                Text(localized: "Dismiss")
            }
        } message: {
            Text(localized: "Your changes will take affect only quitting and restarting DNS Inspector")
        }

    }
}

#Preview {
    AppLanguageView()
}
