import SwiftUI
import DNSKit

struct RecordViewSOA: View {
    let data: SOARecordData

    var body: some View {
        VStack(alignment: .leading) {
            TitleValue(localizedTitle: "Main name server") {
                Text(data.mname)
                    .fixedwidth()
                    .textSelection(.enabled)
            }.padding(.bottom, 2)
            TitleValue(localizedTitle: "Administrative address") {
                Text(data.rname)
                    .fixedwidth()
                    .textSelection(.enabled)
            }
            Divider()
                .padding(.bottom, 2)
                .padding(.top, 2)
            TitleValue(localizedTitle: "Serial") {
                Text("\(data.serial)")
                    .fixedwidth()
                    .textSelection(.enabled)
            }.padding(.bottom, 2)
            TitleValue(localizedTitle: "Refresh") {
                Text("\(data.refresh)")
                    .fixedwidth()
                    .textSelection(.enabled)
            }.padding(.bottom, 2)
            TitleValue(localizedTitle: "Retry") {
                Text("\(data.retry)")
                    .fixedwidth()
                    .textSelection(.enabled)
            }.padding(.bottom, 2)
            TitleValue(localizedTitle: "Expire") {
                Text("\(data.expire)")
                    .fixedwidth()
                    .textSelection(.enabled)
            }.padding(.bottom, 2)
            TitleValue(localizedTitle: "Minimum") {
                Text("\(data.minimum)")
                    .fixedwidth()
                    .textSelection(.enabled)
            }
        }
    }
}
