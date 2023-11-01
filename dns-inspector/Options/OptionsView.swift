import SwiftUI

struct OptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ttlDisplaymode = UserOptions.ttlDisplayMode

    var body: some View {
        Navigation {
            List {
                Section("General") {
                    Toggle("Remember recent queries", isOn: .init(get: {
                        return UserOptions.rememberQueries
                    }, set: { on in
                        UserOptions.rememberQueries = on
                    })).tint(Color.accentColor)

                    Toggle("Show tips", isOn: .init(get: {
                        return UserOptions.showTips
                    }, set: { on in
                        UserOptions.showTips = on
                    })).tint(Color.accentColor)

                    Picker("Show TTL values as", selection: $ttlDisplaymode) {
                        Text("Relative").tag(TTLDisplayMode.relative)
                        Text("Absolute").tag(TTLDisplayMode.absolute)
                    }

                    NavigationLink("Preset servers") {
                        PresetServerListView()
                    }
                }
            }
            .navigationTitle("Options")
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
