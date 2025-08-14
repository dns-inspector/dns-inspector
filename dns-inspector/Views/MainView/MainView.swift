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
import StoreKit

@MainActor
private class MainViewState: ObservableObject {
    @Published var loading = false
    @Published var query: Query?
    @Published var result: DNSKit.Message?
    @Published var error: Error?
    @Published var success = false
}

@MainActor
private class MainViewQueryState: ObservableObject {
    @Published var recordType: RecordType
    @Published var name: String
    @Published var resolver: DNSResolver

    init(recordType: RecordType = RecordType.A, name: String = "", resolver: DNSResolver) {
        self.recordType = recordType
        self.name = name
        self.resolver = resolver
    }
}

struct MainView: View {
    @StateObject private var query: MainViewQueryState
    @StateObject private var lookupState = MainViewState()
    @State private var showAboutView = false
    @State private var showOptionsView = false

    init() {
        _query = StateObject(wrappedValue: MainViewQueryState(resolver: UserOptions.lastUsedServer ?? DNSResolver(type: .DNS, address: "", id: UUID())))
    }

    var body: some View {
        Navigation {
            List {
                Section(Localize.newquery()) {
                    MainViewNameInput(recordType: $query.recordType, name: $query.name)
                    .disabled(self.lookupState.loading)
                    MainViewServerInput(resolver: $query.resolver) {
                        Task {
                            await doInspect()
                        }
                    }
                    .disabled(self.lookupState.loading)
                    if self.lookupState.loading {
                        HStack {
                            ProgressView()
                            Text(Localize.loading())
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
                            await doInspect(recordType: query.recordType, name: query.name, resolver: query.resolver)
                        }
                    }
                }
            }
            .navigationTitle(Localize.dnsinspector())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Menu {
                        Button(action: {
                            self.showAboutView.toggle()
                        }, label: {
                            Label(Localize.about(), systemImage: "info.circle.fill")
                        })
                        Button(action: {
                            self.showOptionsView.toggle()
                        }, label: {
                            Label(Localize.options(), systemImage: "gearshape.circle.fill")
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
        return self.query.resolver.address.isEmpty
    }

    func doInspect() async {
        await doInspect(recordType: self.query.recordType, name: self.query.name, resolver: self.query.resolver)
    }

    func doInspect(recordType: RecordType, name: String, resolver: DNSResolver) async {
        withAnimation {
            self.lookupState.loading = true
            self.lookupState.error = nil
        }

        let transportOptions = TransportOptions(dnsPrefersTcp: UserOptions.dnsPrefersTcp, timeout: UserOptions.timeoutSeconds, httpsServerAddress: resolver.httpsBootstrapIp)
        let queryOptions = QueryOptions(dnssecRequested: true)
        let query: Query
        do {
            query = try Query(transportType: resolver.type, transportOptions: transportOptions, serverAddress: resolver.address, recordType: recordType, name: name, queryOptions: queryOptions)
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
        RecentQueryManager.shared.add(RecentQuery(recordType: query.recordType, name: query.name, resolver: resolver))
        if UserOptions.rememberLastServer {
            UserOptions.lastUsedServer = resolver
        }
    }
}

#Preview {
    MainView()
}
