import SwiftUI
import DNSKit

public struct DNSMessageDNSSECView: View {
    public let query: Query
    public let message: DNSKit.Message
    @State private var result: Result<DNSSECResult, Error>?

    public var body: some View {
        List {
            switch self.result {
            case .success(let dnssecResult):
                Section(Localize("Results")) {
                    HStack {
                        Text(localized: "Signature")
                        Spacer()
                        if dnssecResult.signatureVerified {
                            RoundedLabel(text: Localize("Verified"), color: .green)
                        } else {
                            RoundedLabel(text: Localize("Unverified"), color: .red)
                        }
                    }
                    if let signatureError = dnssecResult.signatureError {
                        VStack(alignment: .leading) {
                            ErrorCellView(error: signatureError, titleKey: "Signature Validation Failed")
                        }
                    }
                    HStack {
                        Text(localized: "Chain")
                        Spacer()
                        if dnssecResult.chainTrusted {
                            RoundedLabel(text: Localize("Trusted"), color: .green)
                        } else {
                            RoundedLabel(text: Localize("Untrusted"), color: .red)
                        }
                    }
                    if let chainError = dnssecResult.chainError {
                        VStack(alignment: .leading) {
                            ErrorCellView(error: chainError, titleKey: "Trust Establishment Failed")
                        }
                    }
                }
                ForEach(dnssecResult.resources, id: \.zone) { zone in
                    Section(zone.zone) {
                        ForEach(zone.dnsKeys) { dnskeyAnswer in
                            // DNSKit does this validation for us
                            // swiftlint:disable force_cast
                            RecordViewDNSKEY(data: dnskeyAnswer.data as! DNSKEYRecordData)
                            // swiftlint:enable force_cast
                        }
                    }
                }
            case .failure(let error):
                ErrorCellView(error: error)
            case nil:
                ProgressView().onAppear {
                    Task {
                        await self.doValidation()
                    }
                }
            }
        }.navigationTitle("DNSSEC")
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
