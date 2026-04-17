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

struct SavedServerEditView: View {
    @Binding public var serverName: String
    @Binding public var transportType: TransportType
    @Binding public var serverAddresses: [String]
    @Binding public var httpsBootstrapIps: [String]
    @Binding public var useHttp2: Bool
    public let isNew: Bool
    public let didSave: () -> Void
    @State private var validationError: Error?
    @Environment(\.presentationMode) var presentation

    var body: some View {
        List {
            if let error = validationError {
                Section {
                    HStack(alignment: .top) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        VStack(alignment: .leading) {
                            Text(Localize.unabletosaveyourchanges()).bold()
                            Text(localizedErrorDetails(error))
                        }
                    }
                    .listRowBackground(Color.red)
                }
            }
            Section(Localize.serverdetails()) {
                VStack(alignment: .leading) {
                    Text(Localize.friendlyname())
                    TextField(Localize.myserver(), text: $serverName)
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
            }
            Section {
                ForEach($serverAddresses.indices, id: \.self) { index in
                    // Have to use string interpolation here because otherwise the link is made blue. you can't tap on it,
                    // but its blue. user inputted text isnt blue, but swiftui decided that the placeholder should be blue.
                    // who asked for this??? why is this the default?????? why isn't anyone answering my questions????????
                    TextField("\(transportType == .HTTPS ? "https://example.com/dns-query" : "192.0.2.1")", text: $serverAddresses[index])
                        .font(Font.custom("Menlo", size: 16, relativeTo: .body))
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                }
            } header: {
                HStack {
                    Text(transportType == .HTTPS ? Localize.serverurl() : Localize.serveraddresses())
                    if transportType != .HTTPS {
                        Spacer()
                        Button {
                            self.serverAddresses.append("")
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            } footer: {
                Text(transportType == .HTTPS ? Localize.dnsservertargethelpurl() : Localize.dnsservertargethelpdns())
            }
            if transportType == .HTTPS {
                Section {
                    ForEach($httpsBootstrapIps.indices, id: \.self) { index in
                        TextField("192.0.2.1", text: $httpsBootstrapIps[index])
                            .font(Font.custom("Menlo", size: 16, relativeTo: .body))
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .submitLabel(.done)
                    }
                } header: {
                    HStack {
                        Text(Localize.serveripaddressesoptional())
                        Spacer()
                        Button {
                            self.httpsBootstrapIps.append("")
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                } footer: {
                    Text(Localize.dnsserverdohbootstrap())
                }
                Section {
                    Toggle(Localize.usehttp2(), isOn: $useHttp2)
                        .tint(Color.accentColor)
                        .disabled(self.hasAtLeastOneBootstrapIp())
                } footer: {
                    Text(Localize.http2bootstrapipfooter())
                }
            }
        }
        .navigationTitle(isNew ? Localize.newsavedserver() : Localize.editsavedserver())
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(Localize.save()) {
                    self.serverAddresses.removeAll(where: \.isEmpty)
                    self.httpsBootstrapIps.removeAll(where: \.isEmpty)
                    if let err = Query.validateConfiguration(transportType: self.transportType, serverAddresses: self.serverAddresses, bootstrapIps: self.httpsBootstrapIps) {
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
                .disabled(isInvalid())
            }
        }
        .onChange(of: httpsBootstrapIps) { _ in
            if hasAtLeastOneBootstrapIp() && useHttp2 {
                self.useHttp2 = false
            }
        }
    }

    func hasAtLeastOneBootstrapIp() -> Bool {
        if self.httpsBootstrapIps.count == 0 {
            return false
        }

        return self.httpsBootstrapIps.first(where: { !$0.isEmpty }) != nil
    }

    func isInvalid() -> Bool {
        if self.serverName.isEmpty {
            return true
        }

        var addresses = self.serverAddresses
        addresses.removeAll(where: \.isEmpty)
        if addresses.isEmpty {
            return true
        }

        return false
    }
}
