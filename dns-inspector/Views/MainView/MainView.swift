import SwiftUI
import DNSKit
import StoreKit

private class MainViewState: ObservableObject {
    @Published var loading = false
    @Published var query: Query?
    @Published var result: DNSKit.Message?
    @Published var error: Error?
    @Published var success = false
}

private class MainViewQueryState: ObservableObject {
    @Published var recordType = RecordType.A
    @Published var name = ""
    @Published var transportType = UserOptions.lastUsedServer?.transportType ?? TransportType.DNS
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
                    MainViewServerInput(transportType: $query.transportType, serverAddress: $query.serverAddress) {
                        Task {
                            await doInspect()
                        }
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
                        Task {
                            await doInspect(recordType: query.recordType, name: query.name, transportType: query.transportType, serverAddress: query.serverAddress)
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
                        Task {
                            await doInspect()
                        }
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

    func doInspect() async {
        await doInspect(recordType: self.query.recordType, name: self.query.name, transportType: self.query.transportType, serverAddress: self.query.serverAddress)
    }

    func doInspect(recordType: RecordType, name: String, transportType: TransportType, serverAddress: String) async {
        withAnimation {
            self.lookupState.loading = true
            self.lookupState.error = nil
        }

        let transportOptions = TransportOptions(dnsPrefersTcp: UserOptions.dnsPrefersTcp)
        let queryOptions = QueryOptions(dnssecRequested: UserOptions.enableDnssec)
        let query: Query
        do {
            query = try Query(transportType: transportType, transportOptions: transportOptions, serverAddress: serverAddress, recordType: recordType, name: name, queryOptions: queryOptions)
        } catch {
            withAnimation {
                self.lookupState.error = error
                self.lookupState.loading = false
            }
            return
        }

        let message: DNSKit.Message
        do {
            message = try await query.execute()
        } catch {
            withAnimation {
                self.lookupState.error = error
                self.lookupState.loading = false
            }
            return
        }

        self.lookupState.error = nil
        self.lookupState.loading = false
        self.lookupState.result = message
        self.lookupState.query = query
        self.lookupState.success = true
        RecentQueryManager.shared.add(RecentQuery(recordType: query.recordType, name: query.name, transportType: query.transportType, serverAddress: query.serverAddress))
        if UserOptions.rememberLastServer {
            UserOptions.lastUsedServer = LastUsedServer(transportType: self.query.transportType, address: self.query.serverAddress)
        }
    }
}

#Preview {
    MainView()
}
