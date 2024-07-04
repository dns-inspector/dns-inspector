import SwiftUI
import DNSKit

struct MainViewRecentLookups: View {
    let onTap: (RecentQuery) -> Void

    var body: some View {
        Section(Localize("Recent queries")) {
            ForEach(RecentQueryManager.shared.queries) { query in
                Button {
                    onTap(query)
                } label: {
                    HStack {
                        RoundedLabel(text: query.recordType.string(), textColor: .primary, borderColor: .gray)
                        Text(query.name)
                        Divider()
                        RoundedLabel(text: query.transportType.string(), textColor: .primary, borderColor: .gray)
                        Text(query.serverAddress)
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
