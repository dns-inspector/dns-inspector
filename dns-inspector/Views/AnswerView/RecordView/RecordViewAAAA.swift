import SwiftUI
import DNSKit

struct RecordViewAAAA: View {
    let data: AAAARecordData

    var body: some View {
        Text(data.ipAddress)
            .fixedwidth()
            .textSelection(.enabled)
    }
}
