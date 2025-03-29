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

struct RecordViewHTTPS: View {
    let data: HTTPSRecordData

    var body: some View {
        VStack(alignment: .leading) {
            TitleValue(localizedTitle: "Priority") {
                Text(String(data.priority))
            }.padding(.bottom, 2)
            TitleValue(localizedTitle: "Target") {
                Text(data.target)
            }.padding(.bottom, 2)
            if data.noDefaultAlpn ?? false {
                Text(localized: "No default ALPN").padding(.bottom, 2)
            }
            if let versions = data.alpn {
                TitleValue(localizedTitle: "Supported Versions") {
                    Text(versions.map({ String(describing: $0 )}).joined(separator: ", "))
                }.padding(.bottom, 2)
            }
            if let v4Hints = data.ipv4Hint {
                TitleValue(localizedTitle: "IPv4 Hints") {
                    Text(v4Hints.joined(separator: ", "))
                }.padding(.bottom, 2)
            }
            if let v6Hints = data.ipv4Hint {
                TitleValue(localizedTitle: "IPv6 Hints") {
                    Text(v6Hints.joined(separator: ", "))
                }.padding(.bottom, 2)
            }
            if let port = data.port {
                TitleValue(localizedTitle: "Port") {
                    Text(String(port))
                }.padding(.bottom, 2)
            }
            if let ech = data.ech {
                TitleValue(title: "ECH") {
                    Text(ech.base64EncodedString())
                        .fixedwidth()
                        .fixedSize(horizontal: false, vertical: true)
                        .fixedSize(horizontal: false, vertical: true)
                }.padding(.bottom, 2)
            }
        }
    }
}
