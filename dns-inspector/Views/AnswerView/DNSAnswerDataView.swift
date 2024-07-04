import SwiftUI
import DNSKit

struct DNSAnswerDataView: View {
    let answer: Answer
    let onCopyRecord: () -> Void

    var body: some View {
        // TODO: break this out into separate files
        HStack {
            switch answer.recordType {
            case .A:
                if let data = answer.data as? ARecordData {
                    Text(data.ipAddress)
                        .fixedwidth()
                        .textSelection(.enabled)
                } else {
                    Text(answer.hexValue)
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .NS:
                if let data = answer.data as? NSRecordData {
                    Text(data.name)
                        .fixedwidth()
                        .textSelection(.enabled)
                } else {
                    Text(answer.hexValue)
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .CNAME:
                if let data = answer.data as? CNAMERecordData {
                    Text(data.name)
                        .fixedwidth()
                        .textSelection(.enabled)
                } else {
                    Text(answer.hexValue)
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .SOA:
                if let data = answer.data as? SOARecordData {
                    RecordViewSOA(data: data)
                } else {
                    Text(answer.hexValue)
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .AAAA:
                if let data = answer.data as? AAAARecordData {
                    Text(data.ipAddress)
                        .fixedwidth()
                        .textSelection(.enabled)
                } else {
                    Text(answer.hexValue)
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .SRV:
                if let data = answer.data as? SRVRecordData {
                    RecordViewSRV(data: data)
                } else {
                    Text(answer.hexValue)
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .TXT:
                if let data = answer.data as? TXTRecordData {
                    Text(data.text)
                        .fixedwidth()
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
            case .MX:
                if let data = answer.data as? MXRecordData {
                    HStack {
                        RoundedLabel(text: "\(data.priority)", color: .primary)
                        Divider()
                        Text(data.name)
                            .fixedwidth()
                            .textSelection(.enabled)
                    }
                } else {
                    Text(answer.hexValue)
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .PTR:
                if let data = answer.data as? PTRRecordData {
                    Text(data.name)
                        .fixedwidth()
                        .textSelection(.enabled)
                } else {
                    Text(answer.hexValue)
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .DS:
                if let data = answer.data as? DSRecordData {
                    RecordViewDS(data: data)
                } else {
                    Text(answer.hexValue)
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .DNSKEY:
                if let data = answer.data as? DNSKEYRecordData {
                    RecordViewDNSKEY(data: data)
                } else {
                    Text(answer.hexValue)
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .RRSIG:
                EmptyView()
            }
        }.contextMenu(menuItems: {
            Button {
                UIPasteboard.general.string = answer.data.description
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
