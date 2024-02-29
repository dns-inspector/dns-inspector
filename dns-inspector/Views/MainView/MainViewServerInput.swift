import SwiftUI
import DNSKit

struct MainViewServerInput: View {
    @Binding var clientType: ClientType
    @Binding var serverAddress: String
    let onSubmit: () -> Void

    var body: some View {
        HStack {
            Menu {
                ForEach(ClientTypes) { t in
                    Button(action: {
                        clientType = t
                    }, label: {
                        Text(t.name)
                    })
                }
            } label: {
                Text(clientType.name)
                Image(systemName: "chevron.up.chevron.down")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 12)
            }
            Divider()
            TextField(text: $serverAddress) {
                Text(localized: serverPlaceholder())
            }
            .keyboardType(.URL)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .submitLabel(.done)
            .onSubmit {
                onSubmit()
            }
            ClearButton(text: $serverAddress)
            PresetServerButton(clientType: $clientType, serverAddress: $serverAddress)
        }
    }

    func serverPlaceholder() -> String {
        switch clientType.dnsKitValue {
        case DNSClientType.DNS.rawValue:
            return "Server IP"
        case DNSClientType.TLS.rawValue:
            return "Server IP"
        case DNSClientType.HTTPS.rawValue:
            return "Server URL"
        default:
            return "Server"
        }
    }
}
