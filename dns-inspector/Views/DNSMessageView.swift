import SwiftUI
import DNSKit

struct DNSMessageView: View {
    let query: DNSQuery
    let message: DNSMessage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Navigation {
            List {
                Section(Localize("Query")) {
                    HStack {
                        Text(String(message.idNumber)).fixedwidth()
                        Divider()
                        RoundedLabel(text: "\(ClientType.fromDNSKit(query.clientType).name)", textColor: .primary, borderColor: .gray)
                        Divider()
                        Text(query.serverAddress).fixedwidth()
                    }
                }
                Section(Localize("Response")) {
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
                    Section(Localize("Question")) {
                        ForEach(questions, id: \.self) { question in
                            DNSQuestionView(question: question)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
                if let answers = message.answers {
                    Section {
                        ForEach(answers, id: \.self) { answer in
                            DNSAnswerView(answer: answer).listRowSeparator(.hidden)
                        }
                    } header: {
                        Text(localized: "Answers")
                    } footer: {
                        VStack(alignment: .leading, spacing: 8.0) {
                            ForEach(answerRecordTypes(answers)) { recordType in
                                VStack(alignment: .leading, spacing: 1.5) {
                                    HStack(spacing: 2.0) {
                                        Image(systemName: "info.circle")
                                            .foregroundStyle(.accent)
                                        Text(localized: "{record type} Record", args: [recordType.name])
                                            .bold()
                                            .foregroundStyle(.accent)
                                    }
                                    Text(localized: "record_description_\(recordType.name.lowercased())")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(localized: "Results")
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
            let elapsedStr = String(format: "%.2f", elapsed / 1000000000)
            return Localize("{duration} seconds", args: [elapsedStr])
        } else if elapsed > 1000000 {
            let elapsedStr = String(format: "%.2f", elapsed / 1000000)
            return Localize("{duration} milliseconds", args: [elapsedStr])
        } else if elapsed > 1000 {
            let elapsedStr = String(format: "%.2f", elapsed / 1000)
            return Localize("{duration} microseconds", args: [elapsedStr])
        }

        let elapsedStr = String(format: "%.2f", elapsed)
        return Localize("{duration} nanoseconds", args: [elapsedStr])
    }

    func answerRecordTypes(_ answers: [DNSAnswer]) -> [RecordType] {
        if !UserOptions.showRecordDescription {
            return []
        }

        var answerTypes: [RecordType] = []

        for answer in answers {
            if let recordType = RecordType.fromDNSKit(answer.recordType) {
                if !answerTypes.contains(recordType) {
                    answerTypes.append(recordType)
                }
            }
        }

        return answerTypes
    }
}
