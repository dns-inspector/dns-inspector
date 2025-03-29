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

public struct WHOISView: View {
    public let domain: String
    @State private var whoisResults: Result<[WHOISReply], Error>?

    public var body: some View {
        List {
            switch whoisResults {
            case .success(let results):
                ForEach(results, id: \.server) { reply in
                    Section(reply.server) {
                        Text(reply.data.prefix(100) + "...").fixedwidth()
                        NavigationLink {
                            FullScreenTextView(text: reply.data)
                        } label: {
                            Text(localized: "View All")
                        }
                    }
                }
            case .failure(let error):
                ErrorCellView(error: error)
            case nil:
                ProgressView().onAppear {
                    Task {
                        await loadData()
                    }
                }
            }
        }
        .navigationTitle(localized: "Domain Information")
    }

    private func loadData() async {
        do {
            let response = try await WHOISClient.lookup(domain)
            self.whoisResults = .success(response)
        } catch {
            self.whoisResults = .failure(error)
        }
    }
}

#Preview {
    WHOISView(domain: "example.com")
}
