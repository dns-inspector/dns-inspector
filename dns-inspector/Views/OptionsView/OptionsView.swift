import SwiftUI

struct OptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ttlDisplaymode = UserOptions.ttlDisplayMode

    var body: some View {
        Navigation {
            List {
                Section(Localize("General")) {
                    NavigationLink {
                        AppLanguageView()
                    } label: {
                        Text(localized: "App language")
                    }
                    Toggle(Localize("Remember recent queries"), isOn: .init(get: {
                        return UserOptions.rememberQueries
                    }, set: { on in
                        UserOptions.rememberQueries = on
                    })).tint(Color.accentColor)

                    Toggle(Localize("Remember last server"), isOn: .init(get: {
                        return UserOptions.rememberLastServer
                    }, set: { on in
                        UserOptions.rememberLastServer = on
                    })).tint(Color.accentColor)

                    Toggle(Localize("Show DNS record descriptions"), isOn: .init(get: {
                        return UserOptions.showRecordDescription
                    }, set: { on in
                        UserOptions.showRecordDescription = on
                    })).tint(Color.accentColor)

                    Picker(Localize("Show TTL values as"), selection: $ttlDisplaymode) {
                        Text(localized: "Relative").tag(TTLDisplayMode.relative)
                        Text(localized: "Absolute").tag(TTLDisplayMode.absolute)
                    }

                    NavigationLink(Localize("Preset servers")) {
                        PresetServerListView()
                    }
                }
                Section(Localize("Network")) {
                    Toggle(Localize("Send traditional DNS requests using TCP"), isOn: .init(get: {
                        return UserOptions.dnsPrefersTcp
                    }, set: { on in
                        UserOptions.dnsPrefersTcp = on
                    })).tint(Color.accentColor)
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
            .onChange(of: self.ttlDisplaymode) { newValue in
                UserOptions.ttlDisplayMode = newValue
            }
        }
    }
}

#Preview {
    OptionsView()
}
