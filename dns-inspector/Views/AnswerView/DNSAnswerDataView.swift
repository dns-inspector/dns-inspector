// DNS Inspector
// Copyright (C) 2024 Ian Spence
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

struct DNSAnswerDataView: View {
    let answer: Answer
    let onCopyRecord: () -> Void

    var body: some View {
        HStack {
            if let data = answer.data as? ErrorRecordData {
                ErrorCellView(error: data.error)
            } else {
                RecordDataView(recordType: answer.recordType, data: answer.data)
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

private struct RecordDataView: View {
    let recordType: RecordType
    let data: RecordData

    // Disable force cast as at this point we've already checked for an error type
    // swiftlint:disable force_cast
    var body: some View {
        switch recordType {
        case .A:
            RecordViewA(data: data as! ARecordData)
        case .CNAME, .NS, .PTR:
            RecordViewBasicName(data: data as! BasicNameRecordData)
        case .SOA:
            RecordViewSOA(data: data as! SOARecordData)
        case .AAAA:
            RecordViewAAAA(data: data as! AAAARecordData)
        case .SRV:
            RecordViewSRV(data: data as! SRVRecordData)
        case .TXT:
            RecordViewTXT(data: data as! TXTRecordData)
        case .MX:
            RecordViewMX(data: data as! MXRecordData)
        case .DS:
            RecordViewDS(data: data as! DSRecordData)
        case .RRSIG:
            EmptyView()
        case .DNSKEY:
            RecordViewDNSKEY(data: data as! DNSKEYRecordData)
        }
    }
    // swiftlint:enable force_cast
}
