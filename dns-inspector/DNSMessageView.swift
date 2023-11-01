import SwiftUI
import DNSKit

struct DNSMessageView: View {
    let query: DNSQuery
    let message: DNSMessage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Navigation {
            List {
                Section("Query") {
                    HStack {
                        RoundedLabel(text: OperationCode.fromDNSKit(message.operationCode).name)
                        Divider()
                        RoundedLabel(text: ResponseCode.fromDNSKit(message.responseCode).name)
                        Divider()
                        Text(String(message.idNumber)).fixedwidth()
                    }
                    HStack {
                        RoundedLabel(text: "\(ServerType.fromDNSKit(query.serverType).name)")
                        Divider()
                        Text(query.serverAddress).fixedwidth()
                    }
                }
                if let questions = message.questions {
                    Section("Question") {
                        ForEach (questions, id: \.self) { question in
                            DNSQuestionView(question: question)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
                if let answers = message.answers {
                    Section("Answers") {
                        ForEach (answers, id: \.self) { answer in
                            DNSAnswerView(answer: answer)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
            }
            .navigationTitle("Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
            }
        }
    }
}
