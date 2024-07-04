import SwiftUI
import DNSKit

public struct WHOISView: View {
    public let domain: String
    @State private var whoisResult: Result<String, Error>?

    public var body: some View {
        switch whoisResult {
        case .success(let result):
            VStack(alignment: .leading) {
                ScrollView([.horizontal, .vertical]) {
                    Text(LocalizedStringKey(result))
                        .multilineTextAlignment(.leading)
                        .textSelection(.enabled)
                        .padding()
                }
            }
            .navigationTitle("Domain Information")
        case .failure(let error):
            ErrorCellView(error: error).padding()
        case nil:
            VStack(alignment: .leading, content: {
                ProgressView()
            })
            .padding()
            .onAppear {
                Task {
                    await loadData()
                }
            }
        }
    }

    private func loadData() async {
        do {
            let response = try await WHOIS.lookup(domain)
            self.whoisResult = .success(response)
        } catch {
            self.whoisResult = .failure(error)
        }
    }
}

#Preview {
    WHOISView(domain: "example.com")
}
