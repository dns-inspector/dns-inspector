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

public struct DNSMessageDNSSECView: View {
    public let query: Query
    public let message: DNSKit.Message
    @State private var result: Result<DNSSECResult, Error>?

    public var body: some View {
        List {
            switch self.result {
            case .success(let dnssecResult):
                Section(Localize.results()) {
                    HStack {
                        Text(Localize.signature())
                        Spacer()
                        if dnssecResult.signatureVerified {
                            RoundedLabel(Localize.verified(), color: .green)
                        } else {
                            RoundedLabel(Localize.unverified(), color: .red)
                        }
                    }
                    if let signatureError = dnssecResult.signatureError {
                        VStack(alignment: .leading) {
                            ErrorCellView(error: signatureError, title: Localize.signaturevalidationfailed())
                        }
                    }
                    HStack {
                        Text(Localize.chain())
                        Spacer()
                        if dnssecResult.chainTrusted {
                            RoundedLabel(Localize.trusted(), color: .green)
                        } else {
                            RoundedLabel(Localize.untrusted(), color: .red)
                        }
                    }
                    if let chainError = dnssecResult.chainError {
                        VStack(alignment: .leading) {
                            ErrorCellView(error: chainError, title: Localize.trustestablishmentfailed())
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
