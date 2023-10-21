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
                                Divider()
                                Text("\(question.questionType.rawValue)")
                                Divider()
                                Text("\(question.questionClass)")
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
                                Text("\(answer.data)")
                                Divider()
                                Text("\(answer.recordType.rawValue)")
                                Divider()
                                Text("\(answer.recordClass)")
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
