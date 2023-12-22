import SwiftUI
import DNSKit

struct PresetServerEditView: View {
    @Binding public var serverType: DNSServerType
    @Binding public var serverAddress: String
    public let didSave: () -> Void
    @Environment(\.presentationMode) var presentation

    var body: some View {
        List {
            Picker("Server Type", selection: $serverType) {
                Text("DNS (TCP)").tag(DNSServerType.TCP53)
                Text("HTTPS").tag(DNSServerType.HTTPS)
                Text("TLS").tag(DNSServerType.TLS)
            }
            TextField(text: $serverAddress) {
                Text("Server Address")
            }
            .keyboardType(.URL)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .submitLabel(.done)
        }
        .navigationTitle("Edit Preset Server")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    presentation.wrappedValue.dismiss()
                    self.didSave()
                }
            }
        }
    }
}

#Preview {
    PresetServerEditView(serverType: .constant(.TCP53), serverAddress: .constant("8.8.8.8")) {
        //
    }
}
