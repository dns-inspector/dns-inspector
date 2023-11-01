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
    @State private var queryName = "dns.google"
    @State private var queryServerType: ServerType = ServerTypes[0]
    @State private var queryServerURL = "dns.google:53"
    @State private var showAboutView = false
    @State private var showOptionsView = false
    @StateObject private var lookupState = MainViewState()

    var body: some View {
        Navigation {
            List {
                Section("New query") {
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
                            RoundedLabel(text: self.queryType.name)
                        }
                        .disabled(self.lookupState.loading)
                        Divider()
                        TextField(text: $queryName) {
                            Text("Name")
                        }
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .disabled(self.lookupState.loading)
                    }
                    HStack {
                        Menu {
                            ForEach(ServerTypes) { t in
                                Button(action: {
                                    self.queryServerType = t
                                }, label: {
                                    Text(t.name)
                                })
                            }
                        } label: {
                            RoundedLabel(text: self.queryServerType.name)
                        }
                        .disabled(self.lookupState.loading)
                        Divider()
                        TextField(text: $queryServerURL) {
                            Text("Server")
                        }
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .onSubmit {
                            doInspect()
                        }
                        .disabled(self.lookupState.loading)
                        PresetServerButton(serverType: $queryServerType, serverAddress: $queryServerURL)
                        .disabled(self.lookupState.loading)
                    }
                    if self.lookupState.loading {
                        withAnimation {
                            HStack {
                                ProgressView()
                                Text("Loading...").padding(.leading, 8).opacity(0.5)
                            }
                        }
                    }
                }
                if UserOptions.rememberQueries && RecentQueryManager.shared.queries.count > 0 {
                    Section("Recent queries") {
                        ForEach(RecentQueryManager.shared.queries) { query in
                            Button(action: {
                                doInspect(recordType: DNSRecordType(rawValue: query.recordType)!, name: query.name, serverType: DNSServerType(rawValue: query.serverType)!, serverAddress: query.serverAddress)
                            }, label: {
                                HStack {
                                    RoundedLabel(text: query.recordTypeName(), color: .primary)
                                    Text(query.name)
                                    Divider()
                                    RoundedLabel(text: query.serverTypeName(), color: .primary)
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
            .navigationTitle("DNS Inspector")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Menu {
                        Button(action: {
                            self.showAboutView.toggle()
                        }, label: {
                            Label("About", systemImage: "info.circle.fill")
                        })
                        Button(action: {
                            self.showOptionsView.toggle()
                        }, label: {
                            Label("Options", systemImage: "gearshape.circle.fill")
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

    func isInvalid() -> Bool {
        return self.queryName.isEmpty || self.queryServerURL.isEmpty
    }

    func doInspect() {
        doInspect(recordType: self.queryType.dnsKitValue, name: self.queryName, serverType: DNSServerType(rawValue: self.queryServerType.dnsKitValue)!, serverAddress: self.queryServerURL)
    }

    func doInspect(recordType: DNSRecordType, name: String, serverType: DNSServerType, serverAddress: String) {
        self.lookupState.loading = true

        let query: DNSQuery
        do {
            query = try DNSQuery(serverType: serverType, serverAddress: serverAddress, recordType: recordType, name: name)
        } catch {
            self.lookupState.error = error
            self.lookupState.loading = false
            return
        }

        query.execute { oMessage, oError in
            DispatchQueue.main.async {
                if let error = oError {
                    self.lookupState.error = error
                    self.lookupState.loading = false
                    return
                }
                guard let message = oMessage else {
                    self.lookupState.loading = false
                    return
                }
                self.lookupState.loading = false
                self.lookupState.result = message
                self.lookupState.query = query
                self.lookupState.success = true
                RecentQueryManager.shared.add(RecentQuery(recordType: query.recordType.rawValue, name: query.name, serverType: query.serverType.rawValue, serverAddress: query.serverAddress))
            }
        }
    }
}

#Preview {
    MainView()
}
