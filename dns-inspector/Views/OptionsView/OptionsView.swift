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

struct OptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var rememberQueries = UserOptions.rememberQueries
    @State private var rememberLastServer = UserOptions.rememberLastServer
    @State private var ttlDisplayMode = UserOptions.ttlDisplayMode
    @State private var showRecordDescription = UserOptions.showRecordDescription
    @State private var dnsPrefersTcp = UserOptions.dnsPrefersTcp
    @State private var timeoutSeconds = "\(UserOptions.timeoutSeconds)"

    var body: some View {
        Navigation {
            List {
                Section(Localize("General")) {
                    NavigationLink {
                        AppLanguageView()
                    } label: {
                        Text(localized: "App language")
                    }
                    NavigationLink(Localize("Preset servers")) {
                        PresetServerListView()
                    }
                }
                Section(Localize("Appearance & Behaviour")) {
                    Toggle(Localize("Remember recent queries"), isOn: $rememberQueries).tint(Color.accentColor)
                    Toggle(Localize("Remember last server"), isOn: $rememberLastServer).tint(Color.accentColor)
                    Toggle(Localize("Show DNS record descriptions"), isOn: $showRecordDescription).tint(Color.accentColor)
                    Picker(Localize("Show TTL values as"), selection: $ttlDisplayMode) {
                        Text(localized: "Relative").tag(TTLDisplayMode.relative)
                        Text(localized: "Absolute").tag(TTLDisplayMode.absolute)
                    }
                }
                Section(Localize("Network")) {
                    Toggle(Localize("Send traditional DNS requests using TCP"), isOn: $dnsPrefersTcp)
                    .tint(Color.accentColor)
                    HStack {
                        Text(localized: "Connection Timeout")
                        TextField("Seconds", text: $timeoutSeconds)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                        Text(localized: "Seconds")
                            .foregroundStyle(.gray)
                    }
                }
            }
            .navigationTitle(localized: "Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
            }
            .onChange(of: rememberQueries) { newValue in
                UserOptions.rememberQueries = newValue
            }
            .onChange(of: rememberLastServer) { newValue in
                UserOptions.rememberLastServer = newValue
            }
            .onChange(of: ttlDisplayMode) { newValue in
                UserOptions.ttlDisplayMode = newValue
            }
            .onChange(of: showRecordDescription) { newValue in
                UserOptions.showRecordDescription = newValue
            }
            .onChange(of: dnsPrefersTcp) { newValue in
                UserOptions.dnsPrefersTcp = newValue
            }
            .onChange(of: timeoutSeconds) { newValue in
                guard let timeout = UInt8(newValue) else {
                    return
                }
                UserOptions.timeoutSeconds = timeout
            }
        }
    }
}

#Preview {
    OptionsView()
}
