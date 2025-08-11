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

struct OptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var rememberQueries = UserOptions.rememberQueries
    @State private var queryLimit = UserOptions.queryLimit
    @State private var rememberLastServer = UserOptions.rememberLastServer
    @State private var ttlDisplayMode = UserOptions.ttlDisplayMode
    @State private var showRecordDescription = UserOptions.showRecordDescription
    @State private var dnsPrefersTcp = UserOptions.dnsPrefersTcp
    @State private var timeoutSeconds = "\(UserOptions.timeoutSeconds)"

    var body: some View {
        Navigation {
            List {
                Section(Localize.general()) {
                    NavigationLink {
                        AppLanguageView()
                    } label: {
                        Text(Localize.applanguage())
                    }
                    NavigationLink(Localize.presetservers()) {
                        PresetServerListView()
                    }
                    NavigationLink(Localize.appicon()) {
                        AppIconView()
                    }
                }
                Section(Localize.appearancebehaviour()) {
                    Toggle(Localize.rememberrecentqueries(), isOn: Binding(get: {
                        rememberQueries
                    }, set: { newValue in
                        withAnimation {
                            rememberQueries = newValue
                        }
                    })).tint(Color.accentColor)
                    if rememberQueries {
                        Picker(Localize.maximumhistorysize(), selection: $queryLimit) {
                            Text("5").tag(UInt8(5))
                            Text("10").tag(UInt8(10))
                            Text("20").tag(UInt8(20))
                            Text("50").tag(UInt8(50))
                        }
                    }
                    Toggle(Localize.rememberlastserver(), isOn: $rememberLastServer).tint(Color.accentColor)
                    Toggle(Localize.showdnsrecorddescriptions(), isOn: $showRecordDescription).tint(Color.accentColor)
                    Picker(Localize.showttlvaluesas(), selection: $ttlDisplayMode) {
                        Text(Localize.relative()).tag(TTLDisplayMode.relative)
                        Text(Localize.absolute()).tag(TTLDisplayMode.absolute)
                    }
                }
                Section(Localize.network()) {
                    Toggle(Localize.sendtraditionaldnsrequestsusingtcp(), isOn: $dnsPrefersTcp)
                    .tint(Color.accentColor)
                    HStack {
                        Text(Localize.connectiontimeout())
                        TextField(Localize.seconds(), text: $timeoutSeconds)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                        Text(Localize.seconds())
                            .foregroundStyle(.gray)
                    }
                }
            }
            .navigationTitle(Localize.options())
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
            .onChange(of: queryLimit) { newValue in
                UserOptions.queryLimit = newValue
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
