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

struct RecordViewCAA: View {
    let data: CAARecordData

    var body: some View {
        VStack(alignment: .leading) {
            if data.critical {
                RoundedLabel(Localize.critical(), color: .primary)
                    .padding(.bottom, 2)
            }
            TitleValue(Localize.tag()) {
                FixedWidthText(data.tag)
            }.padding(.bottom, 2)
            TitleValue(Localize.value()) {
                FixedWidthText(data.value)
            }.padding(.bottom, 2)
        }
    }
}
