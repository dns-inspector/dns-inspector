import SwiftUI
import DNSKit

struct PresetServerEditView: View {
    @Binding public var clientType: DNSClientType
    @Binding public var serverAddress: String
    public let didSave: () -> Void
    @Environment(\.presentationMode) var presentation

    var body: some View {
        List {
            Picker("Server Type", selection: $clientType) {
                Text("DNS").tag(DNSClientType.DNS)
                Text("HTTPS").tag(DNSClientType.HTTPS)
                Text("TLS").tag(DNSClientType.TLS)
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
    PresetServerEditView(clientType: .constant(.DNS), serverAddress: .constant("8.8.8.8")) {
        //
    }
}
