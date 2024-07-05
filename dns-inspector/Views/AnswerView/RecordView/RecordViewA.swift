import SwiftUI
import DNSKit

struct RecordViewA: View {
    let data: ARecordData

    var body: some View {
        Text(data.ipAddress)
            .fixedwidth()
            .textSelection(.enabled)
    }
}
