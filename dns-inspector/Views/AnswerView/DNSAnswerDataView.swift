import SwiftUI
import DNSKit

struct DNSAnswerDataView: View {
    let answer: DNSAnswer
    let onCopyRecord: () -> Void

    var body: some View {
        HStack {
            switch answer.recordType {
            case .A:
                if let data = answer.data as? DNSARecordData {
                    Text(data.ipAddress ?? "Unknown")
                        .fixedwidth()
                        .textSelection(.enabled)
                } else {
                    Text(answer.data.hexValue())
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .NS:
                if let data = answer.data as? DNSNSRecordData {
                    Text(data.name ?? "Unknown")
                        .fixedwidth()
                        .textSelection(.enabled)
                } else {
                    Text(answer.data.hexValue())
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .CNAME:
                if let data = answer.data as? DNSCNAMERecordData {
                    Text(data.name ?? "Unknown")
                        .fixedwidth()
                        .textSelection(.enabled)
                } else {
                    Text(answer.data.hexValue())
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .AAAA:
                if let data = answer.data as? DNSAAAARecordData {
                    Text(data.ipAddress ?? "Unknown")
                        .fixedwidth()
                        .textSelection(.enabled)
                } else {
                    Text(answer.data.hexValue())
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .APL:
                Text(answer.data.hexValue())
                    .fixedwidth()
                    .textSelection(.enabled)
            case .SRV:
                if let data = answer.data as? DNSSRVRecordData {
                    HStack {
                        RoundedLabel(text: "\(data.priority ?? -1)", color: .primary)
                        Divider()
                        RoundedLabel(text: "\(data.weight ?? -1)", color: .primary)
                        Divider()
                        RoundedLabel(text: "\(data.port ?? -1)", color: .primary)
                        Divider()
                        Text(data.name ?? "Unknown")
                            .fixedwidth()
                            .textSelection(.enabled)
                    }
                } else {
                    Text(answer.data.hexValue())
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .TXT:
                if let data = answer.data as? DNSTXTRecordData {
                    Text(data.text ?? "Unknown")
                        .fixedwidth()
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
            case .MX:
                if let data = answer.data as? DNSMXRecordData {
                    HStack {
                        RoundedLabel(text: "\(data.priority ?? -1)", color: .primary)
                        Divider()
                        Text(data.name ?? "Unknown")
                            .fixedwidth()
                            .textSelection(.enabled)
                    }
                } else {
                    Text(answer.data.hexValue())
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .PTR:
                if let data = answer.data as? DNSPTRRecordData {
                    Text(data.name ?? "Unknown")
                        .fixedwidth()
                        .textSelection(.enabled)
                } else {
                    Text(answer.data.hexValue())
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            @unknown default:
                Text(answer.data.hexValue())
                    .fixedwidth()
                    .textSelection(.enabled)
            }
        }.contextMenu(menuItems: {
            Button {
                UIPasteboard.general.string = answer.data.stringValue()
            } label: {
                Label("Copy Record Data", systemImage: "doc.on.clipboard")
            }
            Button {
                self.onCopyRecord()
            } label: {
                Label("Copy Entire Record", systemImage: "doc.on.clipboard")
            }
        })
    }
}

#Preview {
    DNSAnswerDataView(answer: DNSAnswer(name: "dns.google.", recordType: .A, recordClass: .IN, ttlSeconds: 1800, data: "8.8.8.8".data(using: .ascii)!)) {
        //
    }
}
