import SwiftUI
import DNSKit

struct RecordViewSRV: View {
    let data: DNSSRVRecordData

    var body: some View {
        HStack {
            RoundedLabel(text: "\(data.priority ?? -1)", color: .primary)
            Divider()
            RoundedLabel(text: "\(data.weight ?? -1)", color: .primary)
            Divider()
            RoundedLabel(text: "\(data.port ?? -1)", color: .primary)
            Divider()
            Text(data.name ?? "Unknown")
                .fixedwidth()
                .textSelection(.enabled)
        }
    }
}
