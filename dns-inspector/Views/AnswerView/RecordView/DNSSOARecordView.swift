import SwiftUI
import DNSKit

struct DNSSOARecordView: View {
    let data: DNSSOARecordData

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(localized: "Main name server").font(.footnote)
                Text(data.mname)
                    .fixedwidth()
                    .textSelection(.enabled)
            }.padding(.bottom, 2)
            VStack(alignment: .leading) {
                Text(localized: "Administrative address").font(.footnote)
                Text(data.rname)
                    .fixedwidth()
                    .textSelection(.enabled)
            }
            Divider()
                .padding(.bottom, 2)
                .padding(.top, 2)
            VStack(alignment: .leading) {
                Text(localized: "Serial").font(.footnote)
                Text("\(data.serial)")
                    .fixedwidth()
                    .textSelection(.enabled)
            }.padding(.bottom, 2)
            VStack(alignment: .leading) {
                Text(localized: "Refresh").font(.footnote)
                Text("\(data.refresh)")
                    .fixedwidth()
                    .textSelection(.enabled)
            }.padding(.bottom, 2)
            VStack(alignment: .leading) {
                Text(localized: "Retry").font(.footnote)
                Text("\(data.retry)")
                    .fixedwidth()
                    .textSelection(.enabled)
            }.padding(.bottom, 2)
            VStack(alignment: .leading) {
                Text(localized: "Expire").font(.footnote)
                Text("\(data.expire)")
                    .fixedwidth()
                    .textSelection(.enabled)
            }.padding(.bottom, 2)
            VStack(alignment: .leading) {
                Text(localized: "Minimum").font(.footnote)
                Text("\(data.minimum)")
                    .fixedwidth()
                    .textSelection(.enabled)
            }
        }
    }
}
