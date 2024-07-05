import SwiftUI
import DNSKit

struct RecordViewBasicName: View {
    let data: BasicNameRecordData

    var body: some View {
        Text(data.name)
            .fixedwidth()
            .textSelection(.enabled)
    }
}
