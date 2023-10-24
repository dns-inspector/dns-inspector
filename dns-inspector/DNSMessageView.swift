import SwiftUI
import DNSKit

struct DNSMessageView: View {
    let query: DNSQuery
    let message: DNSMessage

    var body: some View {
        HStack {
            List {
                if let questions = message.questions {
                    Section("Question") {
                        ForEach (questions, id: \.self) { question in
                            HStack {
                                Text(question.name)
                                Spacer()
                                Divider()
                                Text("\(RecordType.fromDNSKit(question.recordType).name)")
                                Divider()
                                Text("\(RecordClass.fromDNSKit(question.recordClass).name)")
                            }
                        }
                    }
                }
                if let answers = message.answers {
                    Section("Answers") {
                        ForEach (answers, id: \.self) { answer in
                            HStack {
                                Text(answer.name)
                                Divider()
                                switch answer.recordType {
                                case .A, .AAAA, .CNAME:
                                    Text("\(String(data: answer.data, encoding: .ascii) ?? "Unknown")")
                                        .monospaced()
                                case .TXT:
                                    Text("\(String(data: answer.data, encoding: .utf8) ?? "Unknown")")
                                        .monospaced()
                                default:
                                    Text("\(answer.data)")
                                }
                                Spacer()
                                Divider()
                                Text("\(RecordType.fromDNSKit(answer.recordType).name)")
                                Divider()
                                Text("\(RecordClass.fromDNSKit(answer.recordClass).name)")
                            }
                        }
                    }
                }
                Section("Server") {
                    Text("Hi")
                }
            }
            .navigationTitle(query.name)
        }
    }
}
