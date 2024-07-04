import SwiftUI
import DNSKit

struct RecordViewSRV: View {
    let data: SRVRecordData

    var body: some View {
        HStack {
            RoundedLabel(text: "\(data.priority)", color: .primary)
            Divider()
            RoundedLabel(text: "\(data.weight)", color: .primary)
            Divider()
            RoundedLabel(text: "\(data.port)", color: .primary)
            Divider()
            Text(data.name)
                .fixedwidth()
                .textSelection(.enabled)
        }
    }
}
