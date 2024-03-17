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
                loadData()
            }
        }
    }

    private func loadData() {
        WHOISClient.lookupDomain(domain) { oResponse, oError in
            if let response = oResponse {
                whoisResult = .success(response)
            } else if let error = oError {
                whoisResult = .failure(error)
            }
        }
    }
}

#Preview {
    WHOISView(domain: "example.com")
}
