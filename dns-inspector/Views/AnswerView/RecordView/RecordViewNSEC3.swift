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

struct RecordViewNSEC3: View {
    let data: NSEC3RecordData
    let types: [String]

    init(data: NSEC3RecordData) {
        self.data = data
        var types: [String] = []
        for rrtype in data.types {
            if let recordType = RecordType(rawValue: rrtype) {
                types.append(recordType.string())
            } else {
                types.append("\(rrtype)")
            }
        }
        self.types = types
    }

    var body: some View {
        VStack(alignment: .leading) {
            TitleValue(Localize.hashednextname()) {
                FixedWidthText(data: self.data.hashedNextName)
            }
            TitleValue(Localize.recordtypes()) {
                Text(self.types.joined(separator: ", "))
            }
        }
    }
}
