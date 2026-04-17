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

public struct SavedServerButton: View {
    public let onSelect: (DNSResolver) -> Void
    @State private var newServerName = ""
    @State private var newTransportType = TransportType.HTTPS
    @State private var newServerAddresses = [""]
    @State private var newHttpsBootstrapIps: [String] = []
    @State private var useHttp2: Bool = true
    @State private var savedServers: [DNSResolver] = UserOptions.savedServers
    @State private var showEditServerView = false

    public init(_ onSelect: @escaping (DNSResolver) -> Void) {
        self.onSelect = onSelect
    }

    public var body: some View {
        Menu {
            Section(Localize.savedservers()) {
                ForEach(savedServers) { server in
                    Button(action: {
                        self.onSelect(server)
                    }, label: {
                        Text("\(server.type.string()) - \(server.name!)")
                    })
                }
            }
            Button {
                self.showEditServerView.toggle()
            } label: {
                Label(Localize.addsavedserver(), systemImage: "plus")
            }
        } label: {
            Image(systemName: "bolt.fill")
        }
        .onReceive(NotificationCenter.default.publisher(for: presetServerChangedNotification), perform: { _ in
            self.loadServers()
        })
        .sheet(isPresented: $showEditServerView, content: {
            Navigation {
                SavedServerEditView(serverName: $newServerName, transportType: $newTransportType, serverAddresses: $newServerAddresses, httpsBootstrapIps: $newHttpsBootstrapIps, useHttp2: $useHttp2, isNew: true) {
                    let newResolver: DNSResolver
                    if self.newTransportType == .HTTPS && !newHttpsBootstrapIps.isEmpty {
                        newResolver = DNSResolver(name: newServerName, type: newTransportType, addresses: newServerAddresses, httpsBootstrapIps: newHttpsBootstrapIps, id: UUID())
                    } else {
                        newResolver = DNSResolver(name: newServerName, type: newTransportType, addresses: newServerAddresses, id: UUID())
                    }
                    UserOptions.savedServers.append(newResolver)
                    self.onSelect(newResolver)
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
        self.savedServers = UserOptions.savedServers
    }
}
