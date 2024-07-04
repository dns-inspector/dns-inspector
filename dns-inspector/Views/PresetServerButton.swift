import SwiftUI
import DNSKit

public struct PresetServerButton: View {
    @Binding public var transportType: TransportType
    @Binding public var serverAddress: String
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
                        Text("\(server.type.string()) - \(server.address)")
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
                PresetServerEditView(transportType: $newTransportType, serverAddress: $newServerAddress, isNew: true) {
                    UserOptions.presetServers.append(PresetServer(type: newTransportType, address: newServerAddress))
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
