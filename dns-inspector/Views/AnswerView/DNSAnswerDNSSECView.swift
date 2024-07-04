import SwiftUI
import DNSKit

public struct DNSMessageDNSSECView: View {
    public let query: Query
    public let message: DNSKit.Message
    @State private var result: Result<DNSSECResult, Error>?

    public var body: some View {
        Section("DNSSEC") {
            switch result {
            case .success(let dnssecResult):
                HStack {
                    if dnssecResult.signatureVerified {
                        RoundedLabel(text: "Verified", color: .green)
                    } else {
                        RoundedLabel(text: "Unverified", color: .red)
                    }
                    Divider()
                    Text("Message Signature")
                }
                HStack {
                    if dnssecResult.chainTrusted {
                        RoundedLabel(text: "Established", color: .green)
                    } else {
                        RoundedLabel(text: "Broken", color: .red)
                    }
                    Divider()
                    Text("Chain of Trust")
                }
            case .failure(let error):
                ErrorCellView(error: error)
            case nil:
                if UserOptions.automaticDnssecValidation {
                    ProgressView().onAppear {
                        Task {
                            await doValidation()
                        }
                    }
                } else {
                    Button {
                        Task {
                            await doValidation()
                        }
                    } label: {
                        Text(localized: "Validate")
                    }
                }
            }
        }
    }

    private func doValidation() async {
        do {
            let result = try await query.authenticate(message: message)
            self.result = .success(result)
        } catch {
            self.result = .failure(error)
        }
    }
}
