import SwiftUI
import DNSKit

fileprivate class MainViewState: ObservableObject {
    @Published var loading = false
    @Published var result: DNSMessage?
    @Published var error: Error?
}

fileprivate struct QueryResult {
    let query: DNSQuery
    let message: DNSMessage
}

struct MainView: View {
    @State private var queryType: RecordType = RecordTypes[0]
    @State private var queryName = ""
    @State private var queryServerType: ServerType = ServerTypes[0]
    @State private var queryServerURL = ""
    @State private var showAboutView = false
    @State private var showOptionsView = false
    @StateObject private var lookupState = MainViewState()
    @State private var queryResult: QueryResult?

    var body: some View {
        NavigationStack {
            List {
                Section("New Query") {
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
                            Text(self.queryType.name)
                                .padding(.trailing, 5.0)
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
                            Text(self.queryServerType.name)
                                .padding(.trailing, 5.0)
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
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.accent)
                        Text("Did you know?")
                            .bold()
                    }
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas viverra maximus elit at maximus. In mauris enim, pellentesque a gravida at, rutrum sed lectus. Aliquam erat volutpat. Sed bibendum est at pellentesque consectetur. Vestibulum non justo sit amet felis placerat molestie. Vestibulum ac maximus elit, non pellentesque ipsum. Donec malesuada et dui laoreet laoreet.")
                }
                .padding(.horizontal, -16.0)
                .padding(.vertical, -10.0)
                .listRowBackground(Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.0))
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
        .fullScreenCover(isPresented: .init(get: {
            return self.queryResult != nil
        }, set: { v in
            if !v {
                self.queryResult = nil
            }
        }), content: {
            DNSMessageView(query: self.queryResult!.query, message: self.queryResult!.message)
        })
    }

    func isInvalid() -> Bool {
        return self.queryName.isEmpty || self.queryServerURL.isEmpty
    }

    func doInspect() {
        self.lookupState.loading = true

        let query: DNSQuery
        do {
            query = try DNSQuery(serverType: self.queryServerType.dnsKitValue, serverAddress: self.queryServerURL, recordType: self.queryType.dnsKitValue, name: self.queryName)
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
                self.queryResult = QueryResult(query: query, message: message)
            }
        }
    }
}

#Preview {
    MainView()
}
