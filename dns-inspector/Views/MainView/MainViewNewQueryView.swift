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

private enum RequestDestination: UInt8, Sendable, Codable, Hashable, Identifiable {
    case System = 1
    case SavedServer = 2
    case CustomServer = 3

    public var id: Self { return self }
}

public struct MainViewNewQueryView: View {
    public var recordType: Binding<RecordType>
    public var name: Binding<String>
    public var resolver: Binding<DNSResolver>
    public var disabled: Bool
    public var showEditSavedServerView: Binding<Bool>
    private let onSubmit: () -> Void
    @State private var destination: RequestDestination
    @State private var customTransportType: TransportType = .DNS
    @State private var customServerAddress: String = ""
    @State private var selectedSavedServerID: UUID

    public init(recordType: Binding<RecordType>, name: Binding<String>, resolver: Binding<DNSResolver>, disabled: Bool, showEditSavedServerView: Binding<Bool>, onSubmit: @escaping () -> Void) {
        self.recordType = recordType
        self.name = name
        self.resolver = resolver
        self.disabled = disabled
        self.showEditSavedServerView = showEditSavedServerView
        self.onSubmit = onSubmit
        self.selectedSavedServerID = UserOptions.savedServers.first?.id ?? UUID() // Fallback should never happen because UI enforces at least one server

        // Look at the current value of resolver to infer the initial destination value
        if resolver.wrappedValue.type == .System {
            self.destination = .System
        } else if UserOptions.savedServers.first(where: { $0.id == resolver.wrappedValue.id }) != nil {
            self.destination = .SavedServer
        } else {
            self.destination = .CustomServer
            _customServerAddress = .init(initialValue: resolver.wrappedValue.addresses.first ?? "")
            _customTransportType = .init(initialValue: resolver.wrappedValue.type)
        }
    }

    public var body: some View {
        Group {
            // Record Type
            Picker(selection: recordType) {
                ForEach(RecordType.allCases.filter({ return $0.canQuery() }), id: \.self) { t in
                    Text(t.string()).tag(t)
                }
            } label: {
                Text(Localize.recordtype())
            }
            .disabled(self.disabled)

            // Record Name
            LabeledTextField(label: Localize.name()) {
                NameTextField(destination: self.destination, name: name, onSubmit: self.onSubmit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.leading, 20)
                .disabled(self.disabled)
            }

            // Destination
            VStack(alignment: .leading) {
                Text(Localize.destination())
                Picker(selection: Binding(get: {
                    self.destination
                }, set: { newValue in
                    withAnimation {
                        self.destination = newValue
                    }
                })) {
                    Text(Localize.systemdns()).tag(RequestDestination.System)
                    Text(Localize.savedserver()).tag(RequestDestination.SavedServer)
                    Text(Localize.customserver()).tag(RequestDestination.CustomServer)
                } label: { }
                .pickerStyle(.segmented)
            }

            switch destination {
            case .System:
                EmptyView()
            case .SavedServer:
                SavedServerPicker(selectedSavedServer: .init(get: {
                    UserOptions.savedServers.first(where: { $0.id == selectedSavedServerID })!
                }, set: { newValue in
                    self.selectedSavedServerID = newValue.id
                }), showEditSavedServerView: self.showEditSavedServerView)
            case .CustomServer:
                CustomServerView(disabled: self.disabled, customTransportType: $customTransportType, customServerAddress: $customServerAddress, onSubmit: self.onSubmit)
            }
        }
        .onChange(of: customServerAddress) { newValue in
            self.resolver.wrappedValue = DNSResolver(type: customTransportType, addresses: [newValue])
        }
        .onChange(of: customTransportType) { newValue in
            self.resolver.wrappedValue = DNSResolver(type: newValue, addresses: [customServerAddress])
        }
        .onChange(of: selectedSavedServerID) { newValue in
            guard let resolver = UserOptions.savedServers.first(where: { $0.id == newValue }) else {
                return
            }
            self.resolver.wrappedValue = resolver
        }
        .onChange(of: destination) { newValue in
            switch newValue {
            case RequestDestination.System:
                self.resolver.wrappedValue = DNSResolver(type: .System, addresses: [])
            case RequestDestination.SavedServer:
                guard let resolver = UserOptions.savedServers.first(where: { $0.id == selectedSavedServerID }) else {
                    return
                }
                self.resolver.wrappedValue = resolver
            case RequestDestination.CustomServer:
                self.resolver.wrappedValue = DNSResolver(type: customTransportType, addresses: [customServerAddress])
            }
        }
    }

    func selectedSavedServer() -> DNSResolver {
        guard let resolver = UserOptions.savedServers.first(where: { $0.id == selectedSavedServerID }) else {
            return DNSResolver(type: .System, addresses: [])
        }

        return resolver
    }
}

private struct NameTextField: View {
    public let destination: RequestDestination
    public let name: Binding<String>
    public let onSubmit: () -> Void

    public var body: some View {
        Group {
            if destination == .CustomServer {
                TextField(text: name) {
                    Text("example.com")
                }
            } else {
                TextField(text: name) {
                    Text("example.com")
                }
                .submitLabel(.search)
                .onSubmit {
                    self.onSubmit()
                }
            }
        }
        .keyboardType(.URL)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
    }
}

private struct SavedServerPicker: View {
    public let selectedSavedServer: Binding<DNSResolver>
    public let showEditSavedServerView: Binding<Bool>

    public var body: some View {
        HStack {
            Text(Localize.savedserver())
            Spacer()
            Menu {
                ForEach(UserOptions.savedServers) { server in
                    Button("\(server.type.string()) - \(server.name ?? "")") {
                        self.selectedSavedServer.wrappedValue = server
                    }
                }
                Divider()
                Button(Localize.editsavedservers()) {
                    self.showEditSavedServerView.wrappedValue = true
                }
            } label: {
                HStack {
                    Text("\(self.selectedSavedServer.wrappedValue.type.string()) - \(self.selectedSavedServer.wrappedValue.name ?? "")")
                    Image(systemName: "chevron.up.chevron.down").font(.footnote)
                }
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

private struct CustomServerView: View {
    public var disabled: Bool
    public let customTransportType: Binding<TransportType>
    public let customServerAddress: Binding<String>
    private let onSubmit: () -> Void
    private let possibleTransportTypes = TransportType.allCases.filter({ $0 != .System })

    public init(disabled: Bool, customTransportType: Binding<TransportType>, customServerAddress: Binding<String>, onSubmit: @escaping () -> Void) {
        self.disabled = disabled
        self.customTransportType = customTransportType
        self.customServerAddress = customServerAddress
        self.onSubmit = onSubmit
    }

    public var body: some View {
        Group {
            Picker(selection: customTransportType) {
                ForEach(possibleTransportTypes, id: \.rawValue) { t in
                    Text(t.localized()).tag(t)
                }
            } label: {
                Text(Localize.servertype())
            }
            .disabled(self.disabled)
            LabeledTextField(label: customTransportType.wrappedValue.localizedTargetType()) {
                TextField(text: customServerAddress) {
                    Text(customTransportType.wrappedValue.placeholder())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.leading, 20)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .disabled(self.disabled)
                .onSubmit {
                    self.onSubmit()
                }
            }
        }
    }
}

#Preview {
    List {
        MainViewNewQueryView(recordType: .constant(.A), name: .constant(""), resolver: .constant(DNSResolver(type: .DNS, addresses: [])), disabled: false, showEditSavedServerView: .constant(false)) {
            //
        }
    }
}
