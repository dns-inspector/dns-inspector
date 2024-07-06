import SwiftUI
import DNSKit

struct PresetServerEditView: View {
    @Binding public var transportType: TransportType
    @Binding public var serverAddress: String
    public let isNew: Bool
    public let didSave: () -> Void
    @State private var validationError: Error?
    @Environment(\.presentationMode) var presentation

    var body: some View {
        List {
            Picker(Localize("Server Type"), selection: $transportType) {
                Text("DNS").tag(TransportType.DNS)
                Text("HTTPS").tag(TransportType.HTTPS)
                Text("TLS").tag(TransportType.TLS)
            }
            HStack {
                TextField(text: $serverAddress) {
                    Text(localized: "Server Address")
                }
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                ClearButton(text: $serverAddress)
            }
            if let error = self.validationError {
                ErrorCellView(error: error)
            }
        }
        .navigationTitle(localized: (isNew ? "New Preset Server" : "Edit Preset Server"))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(Localize("Save")) {
                    if let err = Query.validateConfiguration(transportType: self.transportType, serverAddress: self.serverAddress) {
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
