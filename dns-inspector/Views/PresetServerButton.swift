import SwiftUI
import DNSKit

public struct PresetServerButton: View {
    @Binding public var serverType: ServerType
    @Binding public var serverAddress: String
    @State private var newServerType = DNSServerType.HTTPS
    @State private var newServerAddress = ""

    public var body: some View {
        Menu {
            Section("Preset Servers") {
                ForEach(UserOptions.presetServers) { server in
                    Button(action: {
                        self.serverType = server.serverType()
                        self.serverAddress = server.address
                    }, label: {
                        Text("\(server.serverType().name) - \(server.address)")
                    })
                }
            }
            NavigationLink {
                PresetServerEditView(serverType: $newServerType, serverAddress: $newServerAddress) {
                    UserOptions.presetServers.append(PresetServer(type: newServerType.rawValue, address: newServerAddress))
                    serverType = ServerType.fromDNSKit(newServerType)
                    serverAddress = newServerAddress
                }
            } label: {
                Label("Add Preset Server", systemImage: "plus")
            }
        } label: {
            Image(systemName: "sparkles.square.filled.on.square")
        }
    }
}
