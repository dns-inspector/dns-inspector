import SwiftUI
import DNSKit

struct PresetServerEditView: View {
    @Binding public var clientType: DNSClientType
    @Binding public var serverAddress: String
    public let isNew: Bool
    public let didSave: () -> Void
    @State private var validationError: Error?
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
            if let error = self.validationError {
                ErrorCellView(error: error)
            }
        }
        .navigationTitle(isNew ? "New Preset Server" : "Edit Preset Server")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if let err = DNSQuery.validateDNSClientConfiguration(with: self.clientType, serverAddress: self.serverAddress, parameters: nil) {
                        withAnimation {
                            self.validationError = err
                        }
                    } else {
                        withAnimation {
                            self.validationError = nil
                            presentation.wrappedValue.dismiss()
                            self.didSave()
                        }
                    }
                }
            }
        }
    }
}
