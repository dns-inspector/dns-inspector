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
    @State private var useSystemLanguage = UserOptions.appLanguage == nil
    @State private var currentLanguage = UserOptions.appLanguage ?? .English
    @State private var showRestartAlert = false

    var body: some View {
        List {
            Section {
                Toggle(isOn: $useSystemLanguage) {
                    Text(Localize.usesystemlanguage())
                }
                .tint(.accent)
            }
            Section {
                ForEach(SupportedLanguages.allCases, id:\.rawValue) { language in
                    Button {
                        currentLanguage = language
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(String.init(describing: language))
                                Text(Localize.percentcomplete(percent: "\(language.percentTranslated)")).font(.caption)
                            }
                            Spacer()
                            if currentLanguage == language {
                                Image(systemName: "checkmark").foregroundStyle(.accent)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(useSystemLanguage)
                }
            } footer: {
                // This is intentionally not localized
                Text("• Spanish translation by Kevin López Brante.\n• German translation by ErminesRoper.\n• Polish translation by @marcinmajsc on Github.\n\nInterested in translating DNS Inspector to another language? Send us a message through the feedback link!")
            }
        }
        .navigationTitle(Localize.applanguage())
        .onChange(of: useSystemLanguage) { newValue in
            if newValue {
                UserOptions.appLanguage = nil
            } else {
                UserOptions.appLanguage = currentLanguage
            }
            showRestartAlert = true
        }
        .onChange(of: currentLanguage) { newLanguage in
            if newLanguage != UserOptions.appLanguage {
                UserOptions.appLanguage = newLanguage
                showRestartAlert = true
            }
        }
        .alert(Localize.applanguage(), isPresented: $showRestartAlert) {
            Button {
                showRestartAlert = false
            } label: {
                Text(Localize.dismiss())
            }
        } message: {
            Text(Localize.yourchangeswilltakeaffectonlyquittingandrestartingdnsinspector())
        }

    }
}

#Preview {
    AppLanguageView()
}
