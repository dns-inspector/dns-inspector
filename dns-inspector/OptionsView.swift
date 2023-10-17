import SwiftUI

struct OptionsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("General") {
                    Toggle("Remember Recent Queries", isOn: .constant(true))
                        .tint(Color.accentColor)
                    Toggle("Show Tips", isOn: .constant(true))
                        .tint(Color.accentColor)
                    NavigationLink("Preset Servers") {
                        Text("hi")
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
