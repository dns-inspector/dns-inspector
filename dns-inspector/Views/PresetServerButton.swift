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

public struct PresetServerButton: View {
    @Binding public var transportType: TransportType
    @Binding public var serverAddress: String
    @State private var newServerName = ""
    @State private var newTransportType = TransportType.HTTPS
    @State private var newServerAddress = ""
    @State private var presetServers: [PresetServer] = UserOptions.presetServers
    @State private var showEditServerView = false

    public var body: some View {
        Menu {
            Section(Localize("Preset Servers")) {
                ForEach(presetServers) { server in
                    Button(action: {
                        self.transportType = server.type
                        self.serverAddress = server.address
                    }, label: {
                        Text("\(server.type.string()) - \(server.name)")
                    })
                }
            }
            Button {
                self.showEditServerView.toggle()
            } label: {
                Label(Localize("Add Preset Server"), systemImage: "plus")
            }
        } label: {
            Image(systemName: "bolt.fill")
        }
        .onReceive(NotificationCenter.default.publisher(for: presetServerChangedNotification), perform: { _ in
            self.loadServers()
        })
        .popover(isPresented: $showEditServerView, content: {
            Navigation {
                PresetServerEditView(serverName: $newServerName, transportType: $newTransportType, serverAddress: $newServerAddress, isNew: true) {
                    UserOptions.presetServers.append(PresetServer(name: newServerName, type: newTransportType, address: newServerAddress))
                    transportType = newTransportType
                    serverAddress = newServerAddress
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            self.showEditServerView.toggle()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
        })
    }

    func loadServers() {
        self.presetServers = UserOptions.presetServers
    }
}
