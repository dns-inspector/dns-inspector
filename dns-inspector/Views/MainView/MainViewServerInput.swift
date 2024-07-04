import SwiftUI
import DNSKit

struct MainViewServerInput: View {
    var transportType: Binding<TransportType>
    var serverAddress: Binding<String>
    let onSubmit: () -> Void

    var body: some View {
        HStack {
            Menu {
                ForEach(TransportType.allCases, id: \.self) { t in
                    Button(action: {
                        transportType.wrappedValue = t
                    }, label: {
                        Text(t.string())
                    })
                }
            } label: {
                Text(transportType.wrappedValue.string())
                Image(systemName: "chevron.up.chevron.down")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 12)
            }
            Divider()
            TextField(text: serverAddress) {
                Text(localized: serverPlaceholder())
            }
            .keyboardType(.URL)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .submitLabel(.done)
            .onSubmit {
                onSubmit()
            }
            ClearButton(text: serverAddress)
            PresetServerButton(transportType: transportType, serverAddress: serverAddress)
        }
    }

    func serverPlaceholder() -> String {
        switch transportType.wrappedValue {
        case .DNS:
            return "Server IP"
        case .TLS:
            return "Server IP"
        case .HTTPS:
            return "Server URL"
        }
    }
}
