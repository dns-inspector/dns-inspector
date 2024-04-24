import SwiftUI
import DNSKit

public struct DNSMessageDNSSECView: View {
    public let query: DNSQuery
    public let message: DNSMessage
    @State private var oResult: DNSSECResult?

    public var body: some View {
        Section("DNSSEC") {
            if let result = oResult {
                HStack {
                    if result.signatureVerified {
                        RoundedLabel(text: "Verified", color: .green)
                    } else {
                        RoundedLabel(text: "Unverified", color: .red)
                    }
                    Divider()
                    Text("Message Signature")
                }
                HStack {
                    if result.chainTrusted {
                        RoundedLabel(text: "Established", color: .green)
                    } else {
                        RoundedLabel(text: "Broken", color: .red)
                    }
                    Divider()
                    Text("Chain of Trust")
                }
            } else {
                if UserOptions.automaticDnssecValidation {
                    ProgressView().onAppear {
                        doValidation()
                    }
                } else {
                    Button {
                        doValidation()
                    } label: {
                        Text(localized: "Validate")
                    }
                }
            }
        }
    }

    private func doValidation() {
        query.authenticateMessage(message) { result in
            self.oResult = result
        }
    }
}
