import SwiftUI
import DNSKit

struct RecordViewTXT: View {
    let data: TXTRecordData

    var body: some View {
        Text(data.text)
            .fixedwidth()
            .textSelection(.enabled)
    }
}
