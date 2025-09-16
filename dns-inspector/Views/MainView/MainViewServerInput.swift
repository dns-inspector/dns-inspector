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
    var resolver: Binding<DNSResolver>
    @State private var useSavedServer: Bool
    @State private var transportType: TransportType
    @State private var server: String
    let onSubmit: () -> Void

    init(resolver: Binding<DNSResolver>, _ onSubmit: @escaping () -> Void) {
        self.resolver = resolver
        self.useSavedServer = resolver.wrappedValue.name != nil
        self.transportType = resolver.wrappedValue.type
        self.server = resolver.wrappedValue.addresses[0]
        self.onSubmit = onSubmit
    }

    var body: some View {
        HStack {
            if self.useSavedServer {
                RoundedLabel(resolver.wrappedValue.type.string().uppercased())
                Text(resolver.wrappedValue.name!)
                Spacer()
                ClearButton {
                    self.useSavedServer = false
                }
            } else {
                Menu {
                    ForEach(TransportType.allCases, id: \.self) { t in
                        Button(action: {
                            self.transportType = t
                        }, label: {
                            Text(t.string())
                        })
                    }
                } label: {
                    Text(self.transportType.string())
                        .layoutPriority(1)
                    Image(systemName: "chevron.up.chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 12)
                }
                Divider()
                TextField(text: $server) {
                    Text(serverPlaceholder())
                }
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                .onSubmit {
                    onSubmit()
                }
                ClearTextButton(text: $server)
            }
            SavedServerButton { resolver in
                self.resolver.wrappedValue = resolver
                self.useSavedServer = true
            }
        }
        .onChange(of: transportType) { _ in
            self.resolver.wrappedValue = DNSResolver(type: self.transportType, addresses: [self.server], id: UUID())
        }
        .onChange(of: server) { _ in
            self.resolver.wrappedValue = DNSResolver(type: self.transportType, addresses: [self.server], id: UUID())
        }
    }

    func serverPlaceholder() -> String {
        switch transportType {
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
