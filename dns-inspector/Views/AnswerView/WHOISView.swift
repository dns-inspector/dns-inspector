// DNS Inspector
// Copyright (C) 2024 Ian Spence
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
