import SwiftUI
import DNSKit

public struct DNSMessageView: View {
    public let query: Query
    public let message: DNSKit.Message
    private let hasRrsig: Bool
    @State private var showWhois = false
    @Environment(\.dismiss) private var dismiss

    public init(query: Query, message: DNSKit.Message) {
        self.query = query
        self.message = message
        self.hasRrsig = message.answers.first {
            return $0.recordType == .RRSIG
        } != nil
    }

    public var body: some View {
        Navigation {
            List {
                Section(Localize("Query")) {
                    HStack {
                        Text(String(message.idNumber)).fixedwidth()
                        Divider()
                        RoundedLabel(text: query.transportType.string(), textColor: .primary, borderColor: .gray)
                        Divider()
                        Text(query.serverAddress).fixedwidth()
                    }
                }
                Section(Localize("Response")) {
                    HStack {
                        RoundedLabel(text: message.responseCode.string(), color: responseCodeColor())
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
                if message.questions.count > 0 {
                    Section(Localize("Question")) {
                        ForEach(message.questions, id: \.name) { question in
                            DNSQuestionView(question: question)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
                if message.answers.count > 0 {
                    Section {
                        ForEach(message.answers) { answer in
                            if isRecordTypeDisplayable(answer.recordType) {
                                DNSAnswerView(answer: answer).listRowSeparator(.hidden)
                            }
                        }
                    } header: {
                        Text(localized: "Answers")
                    } footer: {
                        VStack(alignment: .leading, spacing: 8.0) {
                            ForEach(answerRecordTypes(message.answers), id: \.self) { recordType in
                                VStack(alignment: .leading, spacing: 1.5) {
                                    HStack(spacing: 2.0) {
                                        Image(systemName: "info.circle")
                                            .foregroundStyle(.accent)
                                        Text(localized: "{record type} Record", args: [recordType.string()])
                                            .bold()
                                            .foregroundStyle(.accent)
                                    }
                                    Text(localized: "record_description_\(recordType.string().lowercased())")
                                }
                            }
                        }
                    }
                }
                Section("DNSSEC") {
                    if hasRrsig {
                        NavigationLink {
                            DNSMessageDNSSECView(query: self.query, message: self.message)
                        } label: {
                            Text(localized: "View DNSSEC Information")
                        }
                    } else {
                        Text(localized: "DNSSEC not enabled on this zone, no RRSIG returned.")
                            .foregroundStyle(.gray)
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
                ToolbarItem {
                    Menu {
                        // Can't use a NavigationLink in a menu on older iOS
                        Button {
                            showWhois.toggle()
                        } label: {
                            Label(Localize("Domain Information"), systemImage: "person.text.rectangle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .destination(isPresented: $showWhois) {
                WHOISView(domain: query.name)
            }
        }
    }

    func responseCodeColor() -> Color {
        if message.responseCode == .NOERROR {
            return .green
        } else if message.responseCode == .NXDOMAIN {
            return .yellow
        }
        return .red
    }

    func elapsedString() -> String {
        let elapsed = message.duration

        if elapsed > 1000000000 {
            let elapsedStr = String(format: "%.2f", Double(elapsed) / 1000000000.0)
            return Localize("{duration} seconds", args: [elapsedStr])
        } else if elapsed > 1000000 {
            let elapsedStr = String(format: "%.2f", Double(elapsed) / 1000000.0)
            return Localize("{duration} milliseconds", args: [elapsedStr])
        } else if elapsed > 1000 {
            let elapsedStr = String(format: "%.2f", Double(elapsed) / 1000.0)
            return Localize("{duration} microseconds", args: [elapsedStr])
        }

        let elapsedStr = String(format: "%.2f", elapsed)
        return Localize("{duration} nanoseconds", args: [elapsedStr])
    }

    func answerRecordTypes(_ answers: [Answer]) -> [RecordType] {
        if !UserOptions.showRecordDescription {
            return []
        }

        var answerTypes: [RecordType] = []

        for answer in answers {
            if answerTypes.contains(answer.recordType) {
                continue
            }
            if !isRecordTypeDisplayable(answer.recordType) {
                continue
            }
            answerTypes.append(answer.recordType)
        }

        return answerTypes
    }

    func isRecordTypeDisplayable(_ recordType: RecordType) -> Bool {
        let hiddenTypes: [RecordType] = [
            .RRSIG
        ]

        return !hiddenTypes.contains(recordType)
    }
}
