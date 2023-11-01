import SwiftUI
import DNSKit

struct DNSAnswerView: View {
    let answer: DNSAnswer

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(answer.name)
                    .font(Font.body.bold().smallCaps())
            }
            .padding(8.0)
            .frame(maxWidth: .infinity)
            .background(Color("LightBackground", bundle: nil))
            Text(answer.dataDescription())
                .fixedwidth()
                .textSelection(.enabled)
                .padding(.horizontal)
                .padding(.vertical, 8.0)
            HStack {
                Spacer()
                Text(RecordType.fromDNSKit(answer.recordType).name)
                    .font(Font.body.smallCaps())
                    .padding(.vertical, 8.0)
                Spacer()
                Divider()
                Spacer()
                Text(RecordClass.fromDNSKit(answer.recordClass).name)
                    .font(Font.body.smallCaps())
                    .padding(.vertical, 8.0)
                Spacer()
                Divider()
                Spacer()
                Text("\(answer.ttlSeconds) seconds")
                    .font(Font.body.smallCaps())
                    .padding(.vertical, 8.0)
                Spacer()
            }
            .overlay(Divider(), alignment: .top)
        }
        .frame(maxWidth: .infinity)
        .listRowInsets(EdgeInsets())
    }
}

#Preview {
    Navigation {
        List {
            Section("Answers") {
                DNSAnswerView(answer: DNSAnswer(name: "dns.google.", recordType: .A, recordClass: .IN, ttlSeconds: 1800, data: "8.8.8.8".data(using: .ascii)!))
                DNSAnswerView(answer: DNSAnswer(name: "dns.google.", recordType: .A, recordClass: .IN, ttlSeconds: 1800, data: "8.8.4.4".data(using: .ascii)!))
            }
            .listRowSeparator(.hidden)
        }
    }
}
