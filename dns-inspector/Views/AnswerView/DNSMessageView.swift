// DNS Inspector
// Copyright (C) Ian Spence and other DNS Inspector Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import SwiftUI
import DNSKit

public struct DNSMessageView: View {
    public let query: Query
    public let message: DNSKit.Message
    public let serverAddress: String
    private let hasRrsig: Bool
    @State private var showWhois = false
    @Environment(\.dismiss) private var dismiss

    public init(query: Query, response: Response) {
        self.query = query
        self.message = response.message
        self.serverAddress = response.serverAddress
        self.hasRrsig = message.answers.first {
            return $0.recordType == .RRSIG
        } != nil
    }

    public var body: some View {
        Navigation {
            List {
                Section(Localize.query()) {
                    HStack {
                        Text(String(message.idNumber)).fixedwidth()
                        Divider()
                        RoundedLabel(query.transportType.string(), textColor: .primary, borderColor: .gray)
                        Divider()
                        Text(serverAddress).fixedwidth()
                    }
                }
                Section(Localize.response()) {
                    HStack {
                        RoundedLabel(message.responseCode.string(), color: responseCodeColor())
                        Divider()
                        if message.truncated {
                            RoundedLabel("TRUNC", color: .yellow)
                            Divider()
                        }
                        if message.authoritativeAnswer {
                            RoundedLabel("AUTH", color: .green)
                            Divider()
                        }
                        Text(elapsedString())
                    }
                }
                if message.questions.count > 0 {
                    Section(Localize.question()) {
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
                        Text(Localize.answers())
                    } footer: {
                        VStack(alignment: .leading, spacing: 8.0) {
                            ForEach(answerRecordTypes(message.answers), id: \.self) { recordType in
                                VStack(alignment: .leading, spacing: 1.5) {
                                    HStack(spacing: 2.0) {
                                        Image(systemName: "info.circle")
                                            .foregroundStyle(.accent)
                                        Text(Localize.recordtyperecord(record_type: recordType.string()))
                                            .bold()
                                            .foregroundStyle(.accent)
                                    }
                                    Text(recordType.recordDescription())
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
                            Text(Localize.viewdnssecinformation())
                        }
                    } else {
                        Text(Localize.dnssecnotenabledonthiszonenorrsigreturned())
                            .foregroundStyle(.gray)
                    }
                }
            }
            .navigationTitle(Localize.results())
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
                            Label(Localize.domaininformation(), systemImage: "person.text.rectangle")
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
            return Localize.durationseconds(duration: elapsedStr)
        } else if elapsed > 1000000 {
            let elapsedStr = String(format: "%.2f", Double(elapsed) / 1000000.0)
            return Localize.durationmicroseconds(duration: elapsedStr)
        } else if elapsed > 1000 {
            let elapsedStr = String(format: "%.2f", Double(elapsed) / 1000.0)
            return Localize.durationmicroseconds(duration: elapsedStr)
        }

        let elapsedStr = String(format: "%.2f", elapsed)
        return Localize.durationnanoseconds(duration: elapsedStr)
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
