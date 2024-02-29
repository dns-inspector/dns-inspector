import SwiftUI
import DNSKit
import StoreKit

private class MainViewState: ObservableObject {
    @Published var loading = false
    @Published var query: DNSQuery?
    @Published var result: DNSMessage?
    @Published var error: Error?
    @Published var success = false
}

private class MainViewQueryState: ObservableObject {
    @Published var recordType = RecordTypes[0]
    @Published var name = ""
    @Published var clientType = UserOptions.lastUsedServer?.clientType ?? ClientTypes[0]
    @Published var serverAddress = UserOptions.lastUsedServer?.address ?? ""
}

struct MainView: View {
    @StateObject private var query = MainViewQueryState()
    @StateObject private var lookupState = MainViewState()
    @State private var showAboutView = false
    @State private var showOptionsView = false

    var body: some View {
        Navigation {
            List {
                Section(Localize("New query")) {
                    MainViewNameInput(recordType: $query.recordType, name: $query.name)
                    .disabled(self.lookupState.loading)
                    MainViewServerInput(clientType: $query.clientType, serverAddress: $query.serverAddress) {
                        doInspect()
                    }
                    .disabled(self.lookupState.loading)
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
                    MainViewRecentLookups { query in
                        doInspect(recordType: DNSRecordType(rawValue: query.recordType)!, name: query.name, clientType: DNSClientType(rawValue: query.clientType)!, serverAddress: query.serverAddress)
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
        .onAppear {
            #if !DEBUG
            if UserOptions.appLaunchCount > 5 && !UserOptions.didPromptForReview {
                if let windowScene = UIApplication.shared.connectedScenes.first {
                    // swiftlint:disable:next force_cast
                    SKStoreReviewController.requestReview(in: windowScene as! UIWindowScene)
                }
                UserOptions.didPromptForReview = true
            }
            #endif
            UserOptions.appLaunchCount += 1
        }
    }

    func isInvalid() -> Bool {
        return self.query.name.isEmpty || self.query.serverAddress.isEmpty
    }

    func doInspect() {
        doInspect(recordType: self.query.recordType.dnsKitValue, name: self.query.name, clientType: DNSClientType(rawValue: self.query.clientType.dnsKitValue)!, serverAddress: self.query.serverAddress)
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
                        self.lookupState.error = MakeError("No error or message")
                        self.lookupState.loading = false
                    }
                    return
                }
                self.lookupState.error = nil
                self.lookupState.loading = false
                self.lookupState.result = message
                self.lookupState.query = query
                self.lookupState.success = true
                RecentQueryManager.shared.add(RecentQuery(recordType: query.recordType.rawValue, name: query.name, clientType: query.clientType.rawValue, serverAddress: query.serverAddress))
                if UserOptions.rememberLastServer {
                    UserOptions.lastUsedServer = LastUsedServer(clientType: self.query.clientType, address: self.query.serverAddress)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
