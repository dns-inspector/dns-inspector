import SwiftUI
import DNSKit

struct DNSQuestionView: View {
    let question: DNSQuestion

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(question.name)
                    .font(Font.body.bold().smallCaps())
            }
            .padding(8.0)
            .frame(maxWidth: .infinity)
            .background(Color("LightBackground", bundle: nil))
            HStack {
                Spacer()
                Text(RecordType.fromDNSKit(question.recordType).name)
                    .font(Font.body.smallCaps())
                    .padding(.vertical, 8.0)
                Spacer()
                Divider()
                Spacer()
                Text(RecordClass.fromDNSKit(question.recordClass).name)
                    .font(Font.body.smallCaps())
                    .padding(.vertical, 8.0)
                Spacer()
            }.padding(.top, -8)
        }
        .frame(maxWidth: .infinity)
        .listRowInsets(EdgeInsets())
    }
}

#Preview {
    Navigation {
        List {
            Section(Localize("Questions")) {
                DNSQuestionView(question: DNSQuestion(name: "dns.google.", recordType: .A, recordClass: .IN))
            }
            .listRowSeparator(.hidden)
        }
    }
}
