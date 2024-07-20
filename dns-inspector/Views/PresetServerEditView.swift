// DNS Inspector
// Copyright (C) 2024 Ian Spence
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
