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
            TitleValue(Localize.mainnameserver()) {
                FixedWidthText(data.mname)
            }.padding(.bottom, 2)
            TitleValue(Localize.administrativeaddress()) {
                FixedWidthText(data.rname)
            }
            Divider()
                .padding(.bottom, 2)
                .padding(.top, 2)
            TitleValue(Localize.serial()) {
                FixedWidthText("\(data.serial)")
            }.padding(.bottom, 2)
            TitleValue(Localize.refresh()) {
                FixedWidthText("\(data.refresh)")
            }.padding(.bottom, 2)
            TitleValue(Localize.retry()) {
                FixedWidthText("\(data.retry)")
            }.padding(.bottom, 2)
            TitleValue(Localize.expire()) {
                FixedWidthText("\(data.expire)")
            }.padding(.bottom, 2)
            TitleValue(Localize.minimum()) {
                FixedWidthText("\(data.minimum)")
            }
        }
    }
}
