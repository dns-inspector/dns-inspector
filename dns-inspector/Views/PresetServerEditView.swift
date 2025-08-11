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
            Section {
                HStack {
                    Text(Localize.friendlyname())
                    TextField("My server", text: $serverName)
                        .keyboardType(.asciiCapable)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                Picker(Localize.servertype(), selection: Binding(get: {
                    transportType
                }, set: { newValue in
                    withAnimation {
                        transportType = newValue
                    }
                })) {
                    Text("DNS").tag(TransportType.DNS)
                    Text("HTTPS").tag(TransportType.HTTPS)
                    Text("TLS").tag(TransportType.TLS)
                    Text("QUIC").tag(TransportType.QUIC)
                }
                HStack {
                    Text(transportType == .HTTPS ? Localize.serverurl() : Localize.serveraddress())
                    // Have to use string interpolation here because otherwise the link is made blue. you can't tap on it,
                    // but its blue. user inputted text isnt blue, but swiftui decided that the placeholder should be blue.
                    // who asked for this??? why is this the default??????
                    TextField("\(transportType == .HTTPS ? "https://example.com/dns-query" : "192.0.2.1")", text: $serverAddress)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                }
                if let error = self.validationError {
                    ErrorCellView(error: error)
                }
            } header: {
                Text(Localize.serverdetails())
            } footer: {
                Text(transportType == .HTTPS ? Localize.dnsservertargethelpurl() : Localize.dnsservertargethelpdns())
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
