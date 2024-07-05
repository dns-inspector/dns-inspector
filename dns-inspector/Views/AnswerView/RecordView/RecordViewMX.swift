import SwiftUI
import DNSKit

struct RecordViewMX: View {
    let data: MXRecordData

    var body: some View {
        HStack {
            RoundedLabel(text: "\(data.priority)", color: .primary)
            Divider()
            Text(data.name)
                .fixedwidth()
                .textSelection(.enabled)
        }
    }
}
