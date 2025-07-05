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

struct RecordViewSOA: View {
    let data: SOARecordData

    var body: some View {
        VStack(alignment: .leading) {
            TitleValue(localizedTitle: "Main name server") {
                FixedWidthText(data.mname)
            }.padding(.bottom, 2)
            TitleValue(localizedTitle: "Administrative address") {
                FixedWidthText(data.rname)
            }
            Divider()
                .padding(.bottom, 2)
                .padding(.top, 2)
            TitleValue(localizedTitle: "Serial") {
                FixedWidthText("\(data.serial)")
            }.padding(.bottom, 2)
            TitleValue(localizedTitle: "Refresh") {
                FixedWidthText("\(data.refresh)")
            }.padding(.bottom, 2)
            TitleValue(localizedTitle: "Retry") {
                FixedWidthText("\(data.retry)")
            }.padding(.bottom, 2)
            TitleValue(localizedTitle: "Expire") {
                FixedWidthText("\(data.expire)")
            }.padding(.bottom, 2)
            TitleValue(localizedTitle: "Minimum") {
                FixedWidthText("\(data.minimum)")
            }
        }
    }
}
