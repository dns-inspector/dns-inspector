import SwiftUI
import DNSKit

public struct PresetServerButton: View {
    @Binding public var clientType: ClientType
    @Binding public var serverAddress: String
    @State private var newServerType = DNSClientType.HTTPS
    @State private var newServerAddress = ""

    public var body: some View {
        Menu {
            Section("Preset Servers") {
                ForEach(UserOptions.presetServers) { server in
                    Button(action: {
                        self.clientType = server.clientType()
                        self.serverAddress = server.address
                    }, label: {
                        Text("\(server.clientType().name) - \(server.address)")
                    })
                }
            }
            NavigationLink {
                PresetServerEditView(clientType: $newServerType, serverAddress: $newServerAddress) {
                    UserOptions.presetServers.append(PresetServer(type: newServerType.rawValue, address: newServerAddress))
                    clientType = ClientType.fromDNSKit(newServerType)
                    serverAddress = newServerAddress
                }
            } label: {
                Label("Add Preset Server", systemImage: "plus")
            }
        } label: {
            Image(systemName: "staroflife.circle")
        }
    }
}
