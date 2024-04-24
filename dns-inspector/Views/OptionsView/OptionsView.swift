import SwiftUI

struct OptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var rememberQueries = UserOptions.rememberQueries
    @State private var rememberLastServer = UserOptions.rememberLastServer
    @State private var ttlDisplayMode = UserOptions.ttlDisplayMode
    @State private var showRecordDescription = UserOptions.showRecordDescription
    @State private var dnsPrefersTcp = UserOptions.dnsPrefersTcp
    @State private var enableDnssec = UserOptions.enableDnssec
    @State private var automaticDnssecValidation = UserOptions.automaticDnssecValidation

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
                    .disabled(enableDnssec)
                }
                Section {
                    Toggle(Localize("DNSSEC Enabled"), isOn: $enableDnssec).tint(Color.accentColor)

                    if enableDnssec {
                        Picker(Localize("Perform Validation"), selection: $automaticDnssecValidation) {
                            Text(localized: "Automatically").tag(true)
                            Text(localized: "Manually").tag(false)
                        }
                    }
                } header: {
                    Text("DNSSEC")
                } footer: {
                    Text(localized: "dnssec_footer")
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
            .onChange(of: enableDnssec) { newValue in
                UserOptions.enableDnssec = newValue
                if newValue {
                    dnsPrefersTcp = true
                }
            }
            .onChange(of: automaticDnssecValidation) { newValue in
                UserOptions.automaticDnssecValidation = newValue
            }
        }
    }
}

#Preview {
    OptionsView()
}
