import SwiftUI
import DNSKit

struct PresetServerListView: View {
    @State private var presetServers: [PresetServer] = []
    @State private var newServerType: DNSClientType = .DNS
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
                PresetServerEditView(clientType: $newServerType, serverAddress: $newServerAddress, isNew: true) {
                    UserOptions.presetServers.append(PresetServer(type: newServerType.rawValue, address: newServerAddress))
                    self.loadPresetServers()
                    self.newServerType = .DNS
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

fileprivate struct PresetServerListViewItem: View {
    let onEdit: () -> Void
    @State private var dnsServerType: DNSClientType
    @State private var address: String
    private let clientType: ClientType
    private let serverID: UUID

    public init(presetServer: PresetServer, onEdit: @escaping () -> Void) {
        _dnsServerType = .init(initialValue: DNSClientType(rawValue: presetServer.type)!)
        _address = .init(initialValue: presetServer.address)
        self.clientType = ClientType.fromDNSKit(_dnsServerType.wrappedValue)
        self.serverID = presetServer.id
        self.onEdit = onEdit
    }

    var body: some View {
        NavigationLink {
            PresetServerEditView(clientType: $dnsServerType, serverAddress: $address, isNew: false) {
                for (index, server) in UserOptions.presetServers.enumerated() {
                    if server.id != serverID {
                        continue
                    }

                    let newServer = PresetServer(type: dnsServerType.rawValue, address: address, id: serverID)
                    UserOptions.presetServers[index] = newServer
                    self.onEdit()
                }
            }
        } label: {
            HStack {
                RoundedLabel(text: self.clientType.name)
                Text(address)
            }
        }
    }
}
