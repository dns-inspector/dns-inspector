import SwiftUI

struct OptionsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Navigation {
            List {
                Section("General") {
                    Toggle("Remember Recent Queries", isOn: .init(get: {
                        return UserOptions.rememberQueries
                    }, set: { on in
                        UserOptions.rememberQueries = on
                    })).tint(Color.accentColor)

                    Toggle("Show Tips", isOn: .init(get: {
                        return UserOptions.showTips
                    }, set: { on in
                        UserOptions.showTips = on
                    })).tint(Color.accentColor)

                    NavigationLink("Preset Servers") {
                        PresetServerListView()
                    }
                }
            }
            .navigationTitle("Options")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
            }
        }
    }
}

#Preview {
    OptionsView()
}
