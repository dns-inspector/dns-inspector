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
    @State private var newServerAddress: String = ""
    @State private var newHttpsBootstrapIp: String = ""

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
                SavedServerEditView(serverName: $newServerName, transportType: $newTransportType, serverAddress: $newServerAddress, httpsBootstrapIp: $newHttpsBootstrapIp, isNew: true) {
                    let newResolver: DNSResolver
                    if self.newTransportType == .HTTPS && !newHttpsBootstrapIp.isEmpty {
                        newResolver = DNSResolver(name: newServerName, type: newTransportType, address: newServerAddress, httpsBootstrapIp: newHttpsBootstrapIp, id: UUID())
                    } else {
                        newResolver = DNSResolver(name: newServerName, type: newTransportType, address: newServerAddress, id: UUID())
                    }
                    UserOptions.savedServers.append(newResolver)
                    self.loadPresetServers()
                    self.newServerName = ""
                    self.newTransportType = .DNS
                    self.newServerAddress = ""
                    self.newHttpsBootstrapIp = ""
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
    @State private var address: String
    @State private var httpsBootstrapIp: String
    private let serverID: UUID

    public init(savedServer: DNSResolver, onEdit: @escaping () -> Void) {
        _name = .init(initialValue: savedServer.name ?? "")
        _transportType = .init(initialValue: savedServer.type)
        _address = .init(initialValue: savedServer.address)
        _httpsBootstrapIp = .init(initialValue: savedServer.httpsBootstrapIp ?? "")
        self.serverID = savedServer.id
        self.onEdit = onEdit
    }

    var body: some View {
        NavigationLink {
            SavedServerEditView(serverName: $name, transportType: $transportType, serverAddress: $address, httpsBootstrapIp: $httpsBootstrapIp, isNew: false) {
                for (index, server) in UserOptions.savedServers.enumerated() {
                    if server.id != serverID {
                        continue
                    }

                    let newResolver: DNSResolver
                    if transportType == .HTTPS && !httpsBootstrapIp.isEmpty {
                        newResolver = DNSResolver(name: name, type: transportType, address: address, httpsBootstrapIp: httpsBootstrapIp, id: serverID)
                    } else {
                        newResolver = DNSResolver(name: name, type: transportType, address: address, id: serverID)
                    }

                    UserOptions.savedServers[index] = newResolver
                    self.onEdit()
                }
            }
        } label: {
            HStack {
                RoundedLabel(transportType.string())
                Text(name)
                Text(address).opacity(0.75)
            }
        }
    }
}
