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

struct MainViewRecentLookups: View {
    let onTap: (RecentQuery) -> Void

    var body: some View {
        Section(Localize.recentqueries()) {
            ForEach(RecentQueryManager.shared.queries) { query in
                Button {
                    onTap(query)
                } label: {
                    HStack {
                        RoundedLabel(query.recordType.string(), textColor: .primary, borderColor: .gray)
                            .layoutPriority(2)
                        Text(query.name)
                            .lineLimit(2)
                        Divider()
                        RoundedLabel(query.resolver.type.string(), textColor: .primary, borderColor: .gray)
                            .layoutPriority(2)
                        Text(query.resolver.addresses[0])
                            .lineLimit(2)
                    }
                }
                .buttonStyle(.plain)
                .id(query.id)
            }
            .onDelete { idx in
                RecentQueryManager.shared.delete(idx)
            }
        }
    }
}
