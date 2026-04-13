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
            TitleValue(Localize.priority()) {
                Text(String(data.priority))
            }.padding(.bottom, 2)
            TitleValue(Localize.target()) {
                Text(data.target)
            }.padding(.bottom, 2)
            if data.noDefaultAlpn ?? false {
                Text(Localize.nodefaultalpn()).padding(.bottom, 2)
            }
            if let versions = data.alpn {
                TitleValue(Localize.supportedversions()) {
                    Text(versions.map({ String(describing: $0 )}).joined(separator: ", "))
                }.padding(.bottom, 2)
            }
            if let v4Hints = data.ipv4Hint {
                TitleValue(Localize.ipv4hints()) {
                    Text(v4Hints.joined(separator: ", "))
                }.padding(.bottom, 2)
            }
            if let v6Hints = data.ipv6Hint {
                TitleValue(Localize.ipv6hints()) {
                    Text(v6Hints.joined(separator: ", "))
                }.padding(.bottom, 2)
            }
            if let port = data.port {
                TitleValue(Localize.port()) {
                    Text(String(port))
                }.padding(.bottom, 2)
            }
            if let ech = data.ech {
                TitleValue("ECH") {
                    FixedWidthText(data: ech)
                }.padding(.bottom, 2)
            }
        }
    }
}
