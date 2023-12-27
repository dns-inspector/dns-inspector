import SwiftUI
import DNSKit

public struct PresetServerButton: View {
    @Binding public var clientType: ClientType
    @Binding public var serverAddress: String
    @State private var newServerType = DNSClientType.HTTPS
    @State private var newServerAddress = ""
    @State private var presetServers: [PresetServer] = UserOptions.presetServers
    @State private var showEditServerView = false

    public var body: some View {
        Menu {
            Section(Localize("Preset Servers")) {
                ForEach(presetServers) { server in
                    Button(action: {
                        self.clientType = server.clientType()
                        self.serverAddress = server.address
                    }, label: {
                        Text("\(server.clientType().name) - \(server.address)")
                    })
                }
            }
            Button {
                self.showEditServerView.toggle()
            } label: {
                Label(Localize("Add Preset Server"), systemImage: "plus")
            }
        } label: {
            Image(systemName: "staroflife.circle")
        }
        .onReceive(NotificationCenter.default.publisher(for: presetServerChangedNotification), perform: { _ in
            self.loadServers()
        })
        .popover(isPresented: $showEditServerView, content: {
            Navigation {
                PresetServerEditView(clientType: $newServerType, serverAddress: $newServerAddress, isNew: true) {
                    UserOptions.presetServers.append(PresetServer(type: newServerType.rawValue, address: newServerAddress))
                    clientType = ClientType.fromDNSKit(newServerType)
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
