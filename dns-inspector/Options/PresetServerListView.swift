import SwiftUI
import DNSKit

struct PresetServerListView: View {
    @State private var newServerType: DNSServerType = .TCP53
    @State private var newServerAddress: String = ""

    var body: some View {
        List {
            ForEach(UserOptions.presetServers) { server in
                PresetServerListViewItem(presetServer: server)
            }
            .onDelete { idx in
                UserOptions.presetServers.remove(atOffsets: idx)
            }
        }
        .toolbar(content: {
            NavigationLink {
                PresetServerEditView(serverType: $newServerType, serverAddress: $newServerAddress) {
                    UserOptions.presetServers.append(PresetServer(type: newServerType.rawValue, address: newServerAddress))
                }
            } label: {
                Image(systemName: "plus")
            }
            EditButton()
        })
        .navigationTitle("Preset Servers")
    }
}

fileprivate struct PresetServerListViewItem: View {
    @State private var dnsServerType: DNSServerType
    @State private var address: String
    private let serverType: ServerType
    private let serverID: UUID

    public init(presetServer: PresetServer) {
        _dnsServerType = .init(initialValue: DNSServerType(rawValue: presetServer.type)!)
        _address = .init(initialValue: presetServer.address)
        self.serverType = ServerType.fromDNSKit(_dnsServerType.wrappedValue)
        self.serverID = presetServer.id
    }

    var body: some View {
        NavigationLink {
            PresetServerEditView(serverType: $dnsServerType, serverAddress: $address) {
                for (index, server) in UserOptions.presetServers.enumerated() {
                    if server.id != serverID {
                        continue
                    }

                    let newServer = PresetServer(type: dnsServerType.rawValue, address: address, id: serverID)
                    UserOptions.presetServers[index] = newServer
                }
            }
        } label: {
            HStack {
                RoundedLabel(text: self.serverType.name)
                Text(address)
            }
        }
    }
}
