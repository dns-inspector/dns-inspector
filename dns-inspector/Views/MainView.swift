import SwiftUI
import DNSKit

fileprivate class MainViewState: ObservableObject {
    @Published var loading = false
    @Published var query: DNSQuery?
    @Published var result: DNSMessage?
    @Published var error: Error?
    @Published var success = false
}

struct MainView: View {
    @State private var queryType: RecordType = RecordTypes[0]
    @State private var queryName = ""
    @State private var queryClientType: ClientType = UserOptions.lastUsedServer?.clientType ?? ClientTypes[0]
    @State private var queryServerURL = UserOptions.lastUsedServer?.address ?? ""
    @State private var showAboutView = false
    @State private var showOptionsView = false
    @StateObject private var lookupState = MainViewState()

    var body: some View {
        Navigation {
            List {
                Section(Localize("New query")) {
                    HStack {
                        Menu {
                            ForEach(RecordTypes) { t in
                                Button(action: {
                                    self.queryType = t
                                }, label: {
                                    Text(t.name)
                                })
                            }
                        } label: {
                            HStack {
                                Text(self.queryType.name)
                                Image(systemName: "chevron.up.chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 12)
                            }
                        }
                        .disabled(self.lookupState.loading)
                        Divider()
                        TextField(text: $queryName) {
                            Text(localized: "Name")
                        }
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .disabled(self.lookupState.loading)
                    }
                    HStack {
                        Menu {
                            ForEach(ClientTypes) { t in
                                Button(action: {
                                    self.queryClientType = t
                                }, label: {
                                    Text(t.name)
                                })
                            }
                        } label: {
                            Text(self.queryClientType.name)
                            Image(systemName: "chevron.up.chevron.down")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 12)
                        }
                        .disabled(self.lookupState.loading)
                        Divider()
                        TextField(text: $queryServerURL) {
                            Text(localized: serverPlaceholder())
                        }
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .onSubmit {
                            doInspect()
                        }
                        .disabled(self.lookupState.loading)
                        PresetServerButton(clientType: $queryClientType, serverAddress: $queryServerURL)
                        .disabled(self.lookupState.loading)
                    }
                    if self.lookupState.loading {
                        HStack {
                            ProgressView()
                            Text(localized: "Loading...")
                                .padding(.leading, 8)
                                .foregroundStyle(.gray)
                        }
                    }
                    if let error = self.lookupState.error {
                        ErrorCellView(error: error)
                    }
                }
                if UserOptions.rememberQueries && RecentQueryManager.shared.queries.count > 0 {
                    Section(Localize("Recent queries")) {
                        ForEach(RecentQueryManager.shared.queries) { query in
                            Button(action: {
                                doInspect(recordType: DNSRecordType(rawValue: query.recordType)!, name: query.name, clientType: DNSClientType(rawValue: query.clientType)!, serverAddress: query.serverAddress)
                            }, label: {
                                HStack {
                                    RoundedLabel(text: query.recordTypeName(), textColor: .primary, borderColor: .gray)
                                    Text(query.name)
                                    Divider()
                                    RoundedLabel(text: query.clientTypeName(), textColor: .primary, borderColor: .gray)
                                    Text(query.serverAddress)
                                }
                            }).buttonStyle(.plain)
                        }
                        .onDelete { idx in
                            RecentQueryManager.shared.delete(idx)
                        }
                    }
                }
            }
            .navigationTitle(localized: "DNS Inspector")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Menu {
                        Button(action: {
                            self.showAboutView.toggle()
                        }, label: {
                            Label(Localize("About"), systemImage: "info.circle.fill")
                        })
                        Button(action: {
                            self.showOptionsView.toggle()
                        }, label: {
                            Label(Localize("Options"), systemImage: "gearshape.circle.fill")
                        })
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }

                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        doInspect()
                    }, label: {
                        Image(systemName: "arrow.right.circle")
                    })
                    .disabled(self.isInvalid())
                }
            }
        }
        .sheet(isPresented: $showAboutView, content: {
            AboutView()
        })
        .sheet(isPresented: $showOptionsView, content: {
            OptionsView()
        })
        .fullScreenCover(isPresented: $lookupState.success) {
            DNSMessageView(query: lookupState.query!, message: lookupState.result!)
        }
    }

    func serverPlaceholder() -> String {
        switch self.queryClientType.dnsKitValue {
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

    func isInvalid() -> Bool {
        return self.queryName.isEmpty || self.queryServerURL.isEmpty
    }

    func doInspect() {
        doInspect(recordType: self.queryType.dnsKitValue, name: self.queryName, clientType: DNSClientType(rawValue: self.queryClientType.dnsKitValue)!, serverAddress: self.queryServerURL)
    }

    func doInspect(recordType: DNSRecordType, name: String, clientType: DNSClientType, serverAddress: String) {
        withAnimation {
            self.lookupState.loading = true
        }

        let query: DNSQuery
        do {
            let parameters = DNSQueryParameters()
            parameters.dnsPrefersTcp = UserOptions.dnsPrefersTcp
            query = try DNSQuery(clientType: clientType, serverAddress: serverAddress, recordType: recordType, name: name, parameters: parameters)
        } catch {
            withAnimation {
                self.lookupState.error = error
                self.lookupState.loading = false
            }
            return
        }

        query.execute { oMessage, oError in
            DispatchQueue.main.async {
                if let error = oError {
                    withAnimation {
                        self.lookupState.error = error
                        self.lookupState.loading = false
                    }
                    return
                }
                guard let message = oMessage else {
                    withAnimation {
                        self.lookupState.loading = false
                    }
                    return
                }
                self.lookupState.loading = false
                self.lookupState.result = message
                self.lookupState.query = query
                self.lookupState.success = true
                RecentQueryManager.shared.add(RecentQuery(recordType: query.recordType.rawValue, name: query.name, clientType: query.clientType.rawValue, serverAddress: query.serverAddress))
                if UserOptions.rememberLastServer {
                    UserOptions.lastUsedServer = LastUsedServer(clientType: queryClientType, address: queryServerURL)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
