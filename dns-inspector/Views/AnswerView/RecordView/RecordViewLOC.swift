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

struct RecordViewLOC: View {
    let data: LOCRecordData
    private let latitude: String
    private let longitude: String

    init(data: LOCRecordData) {
        self.data = data
        let (latitude, longitude) = data.degrees()
        self.latitude = latitude
        self.longitude = longitude
    }

    var body: some View {
        VStack(alignment: .leading) {
            TitleValue(Localize.coordinates()) {
                Text("\(self.latitude) \(self.longitude)")
                    .fixedSize(horizontal: false, vertical: true)
            }.padding(.bottom, 2)
            HStack {
                TitleValue(Localize.altitude()) {
                    Text("\(self.data.altitudeMeters)m")
                        .fixedSize(horizontal: false, vertical: true)
                }
                Divider()
                TitleValue(Localize.area()) {
                    Text("\(self.data.sizeMeters)m")
                        .fixedSize(horizontal: false, vertical: true)
                }
            }.padding(.bottom, 2)
            HStack {
                TitleValue(Localize.horizontalprecision()) {
                    Text("\(self.data.horizontalPrecisionMeters)m")
                        .fixedSize(horizontal: false, vertical: true)
                }
                Divider()
                TitleValue(Localize.verticalprecision()) {
                    Text("\(self.data.verticalPrecisionMeters)m")
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
