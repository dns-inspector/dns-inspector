// DNS Inspector
// Copyright (C) Ian Spence and other DNS Inspector Contributors
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
    @Binding public var serverName: String
    @Binding public var transportType: TransportType
    @Binding public var serverAddress: String
    public let isNew: Bool
    public let didSave: () -> Void
    @State private var validationError: Error?
    @Environment(\.presentationMode) var presentation

    var body: some View {
        List {
            Section(Localize.serverdetails()) {
                HStack {
                    Text(Localize.friendlyname())
                    TextField("My server", text: $serverName)
                        .keyboardType(.asciiCapable)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                Picker(Localize.servertype(), selection: $transportType) {
                    Text("DNS").tag(TransportType.DNS)
                    Text("HTTPS").tag(TransportType.HTTPS)
                    Text("TLS").tag(TransportType.TLS)
                }
                HStack {
                    Text(Localize.serveraddress())
                    TextField("192.0.2.1", text: $serverAddress)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                }
                if let error = self.validationError {
                    ErrorCellView(error: error)
                }
            }
        }
        .navigationTitle(isNew ? Localize.newpresetserver() : Localize.editpresetserver())
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(Localize.save()) {
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
