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

struct PresetServerListView: View {
    @State private var savedServers: [DNSResolver] = []
    @State private var newServerName: String = ""
    @State private var newTransportType: TransportType = .DNS
    @State private var newServerAddresses = [""]
    @State private var newHttpsBootstrapIps: [String] = []
    @State private var useHttp2: Bool = true

    var body: some View {
        List {
            ForEach(savedServers) { server in
                SavedServerListViewItem(savedServer: server) {
                    self.loadPresetServers()
                }
            }
            .onDelete { idx in
                UserOptions.savedServers.remove(atOffsets: idx)
                self.loadPresetServers()
            }
        }
        .onAppear {
            loadPresetServers()
        }
        .listStyle(.plain)
        .toolbar(content: {
            NavigationLink {
                SavedServerEditView(serverName: $newServerName, transportType: $newTransportType, serverAddresses: $newServerAddresses, httpsBootstrapIps: $newHttpsBootstrapIps, useHttp2: $useHttp2, isNew: true) {
                    let newResolver: DNSResolver
                    if self.newTransportType == .HTTPS && !newHttpsBootstrapIps.isEmpty {
                        newResolver = DNSResolver(name: newServerName, type: newTransportType, addresses: newServerAddresses, httpsBootstrapIps: newHttpsBootstrapIps, id: UUID())
                    } else {
                        newResolver = DNSResolver(name: newServerName, type: newTransportType, addresses: newServerAddresses, id: UUID())
                    }
                    UserOptions.savedServers.append(newResolver)
                    self.loadPresetServers()
                    self.newServerName = ""
                    self.newTransportType = .DNS
                    self.newServerAddresses = [""]
                    self.newHttpsBootstrapIps = []
                }
            } label: {
                Image(systemName: "plus")
            }
            EditButton()
        })
        .navigationTitle(Localize.presetservers())
    }

    func loadPresetServers() {
        self.savedServers = UserOptions.savedServers
    }
}

private struct SavedServerListViewItem: View {
    let onEdit: () -> Void
    @State private var name: String
    @State private var transportType: TransportType
    @State private var addresses: [String]
    @State private var httpsBootstrapIps: [String]
    @State private var useHttp2: Bool
    private let serverID: UUID

    public init(savedServer: DNSResolver, onEdit: @escaping () -> Void) {
        _name = .init(initialValue: savedServer.name ?? "")
        _transportType = .init(initialValue: savedServer.type)
        _addresses = .init(initialValue: savedServer.addresses)
        _httpsBootstrapIps = .init(initialValue: savedServer.httpsBootstrapIps ?? [])
        _useHttp2 = .init(initialValue: savedServer.useHttp2 ?? true)
        self.serverID = savedServer.id
        self.onEdit = onEdit
    }

    var body: some View {
        NavigationLink {
            SavedServerEditView(serverName: $name, transportType: $transportType, serverAddresses: $addresses, httpsBootstrapIps: $httpsBootstrapIps, useHttp2: $useHttp2, isNew: false) {
                for (index, server) in UserOptions.savedServers.enumerated() {
                    if server.id != serverID {
                        continue
                    }

                    let newResolver: DNSResolver
                    if transportType == .HTTPS && !httpsBootstrapIps.isEmpty {
                        newResolver = DNSResolver(name: name, type: transportType, addresses: addresses, httpsBootstrapIps: httpsBootstrapIps, id: serverID)
                    } else {
                        newResolver = DNSResolver(name: name, type: transportType, addresses: addresses, id: serverID)
                    }

                    UserOptions.savedServers[index] = newResolver
                    self.onEdit()
                }
            }
        } label: {
            HStack {
                RoundedLabel(transportType.string())
                Text(name)
                Text(addresses.first ?? "").opacity(0.75)
            }
        }
    }
}
