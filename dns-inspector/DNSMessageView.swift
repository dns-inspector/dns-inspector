import SwiftUI
import DNSKit

struct DNSMessageView: View {
    let query: DNSQuery
    let message: DNSMessage

    var body: some View {
        HStack {
            List {
                Section("Headers") {
                    HStack {
                        RoundedLabel(text: OperationCode.fromDNSKit(message.operationCode).name)
                        Divider()
                        RoundedLabel(text: ResponseCode.fromDNSKit(message.responseCode).name)
                        Divider()
                        Text(String(message.idNumber)).fixedwidth()
                    }
                }
                if let questions = message.questions {
                    Section("Question") {
                        ForEach (questions, id: \.self) { question in
                            HStack {
                                Text(question.name)
                                    .textSelection(.enabled)
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
                            VStack {
                                HStack {
                                    Text(answer.name)
                                        .textSelection(.enabled)
                                    Divider()
                                    switch answer.recordType {
                                    case .A, .AAAA, .CNAME:
                                        Text("\(String(data: answer.data, encoding: .ascii) ?? "Unknown")")
                                            .fixedwidth()
                                            .textSelection(.enabled)
                                    case .TXT:
                                        Text("\(String(data: answer.data, encoding: .utf8) ?? "Unknown")")
                                            .fixedwidth()
                                            .textSelection(.enabled)
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
                }
                Section("Server") {
                    HStack {
                        RoundedLabel(text: "\(ServerType.fromDNSKit(query.serverType).name)")
                        Divider()
                        Text(query.serverAddress).fixedwidth()
                    }
                }
            }
            .navigationTitle(query.name)
        }
    }
}
