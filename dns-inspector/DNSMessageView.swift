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
                        Text(String(message.idNumber)).fixedwidth()
                        Divider()
                        RoundedLabel(text: "\(ClientType.fromDNSKit(query.clientType).name)", color: Color.primary)
                        Divider()
                        Text(query.serverAddress).fixedwidth()
                    }
                }
                Section("Response") {
                    HStack {
                        RoundedLabel(text: ResponseCode.fromDNSKit(message.responseCode).name, color: responseCodeColor())
                        Divider()
                        if message.truncated {
                            RoundedLabel(text: "TRUNC", color: .yellow)
                            Divider()
                        }
                        if message.authoritativeAnswer {
                            RoundedLabel(text: "AUTH", color: .green)
                            Divider()
                        }
                        Text(elapsedString())
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

    func responseCodeColor() -> Color {
        if message.responseCode == .success {
            return .green
        } else if message.responseCode == .NXDOMAIN {
            return .yellow
        }
        return .red
    }

    func elapsedString() -> String {
        let elapsed = message.elapsedNs.doubleValue

        if elapsed > 1000000000 {
            return String(format: "%.2f seconds", elapsed / 1000000000)
        } else if elapsed > 1000000 {
            return String(format: "%.2f milliseconds", elapsed / 1000000)
        } else if elapsed > 1000 {
            return String(format: "%.2f microseconds", elapsed / 1000)
        }

        return String(format: "%.2f nanoseconds", elapsed)
    }
}
