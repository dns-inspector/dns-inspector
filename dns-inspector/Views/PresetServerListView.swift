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
    @State private var presetServers: [PresetServer] = []
    @State private var newServerName: String = ""
    @State private var newTransportType: TransportType = .DNS
    @State private var newServerAddress: String = ""

    var body: some View {
        List {
            ForEach(presetServers) { server in
                PresetServerListViewItem(presetServer: server) {
                    self.loadPresetServers()
                }
            }
            .onDelete { idx in
                UserOptions.presetServers.remove(atOffsets: idx)
                self.loadPresetServers()
            }
        }
        .onAppear {
            loadPresetServers()
        }
        .listStyle(.plain)
        .toolbar(content: {
            NavigationLink {
                PresetServerEditView(serverName: $newServerName, transportType: $newTransportType, serverAddress: $newServerAddress, isNew: true) {
                    UserOptions.presetServers.append(PresetServer(name: newServerName, type: newTransportType, address: newServerAddress))
                    self.loadPresetServers()
                    self.newServerName = ""
                    self.newTransportType = .DNS
                    self.newServerAddress = ""
                }
            } label: {
                Image(systemName: "plus")
            }
            EditButton()
        })
        .navigationTitle(localized: "Preset Servers")
    }

    func loadPresetServers() {
        self.presetServers = UserOptions.presetServers
    }
}

private struct PresetServerListViewItem: View {
    let onEdit: () -> Void
    @State private var name: String
    @State private var transportType: TransportType
    @State private var address: String
    private let serverID: UUID

    public init(presetServer: PresetServer, onEdit: @escaping () -> Void) {
        _name = .init(initialValue: presetServer.name)
        _transportType = .init(initialValue: presetServer.type)
        _address = .init(initialValue: presetServer.address)
        self.serverID = presetServer.id
        self.onEdit = onEdit
    }

    var body: some View {
        NavigationLink {
            PresetServerEditView(serverName: $name, transportType: $transportType, serverAddress: $address, isNew: false) {
                for (index, server) in UserOptions.presetServers.enumerated() {
                    if server.id != serverID {
                        continue
                    }

                    let newServer = PresetServer(name: name, type: transportType, address: address, id: serverID)
                    UserOptions.presetServers[index] = newServer
                    self.onEdit()
                }
            }
        } label: {
            HStack {
                RoundedLabel(text: transportType.string())
                Text(name)
                Text(address).opacity(0.75)
            }
        }
    }
}
