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
                    .layoutPriority(1)
                Image(systemName: "chevron.up.chevron.down")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 12)
            }
            Divider()
            TextField(text: serverAddress) {
                Text(serverPlaceholder())
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
            return Localize.serverip()
        case .TLS:
            return Localize.serverip()
        case .HTTPS:
            return Localize.serverurl()
        case .QUIC:
            return Localize.serverip()
        }
    }
}
