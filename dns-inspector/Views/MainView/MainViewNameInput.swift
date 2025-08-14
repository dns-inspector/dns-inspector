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

public struct MainViewNameInput: View {
    @Binding public var recordType: RecordType
    @Binding public var name: String
    private let validRecordTypes: [RecordType] = RecordType.allCases.filter({ return $0.canQuery() })

    public var body: some View {
        HStack {
            Menu {
                ForEach(validRecordTypes, id: \.self) { t in
                    Button(action: {
                        recordType = t
                    }, label: {
                        Text(t.string())
                    })
                }
            } label: {
                HStack {
                    Text(recordType.string())
                        .layoutPriority(1)
                    Image(systemName: "chevron.up.chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 12)
                }
            }
            Divider()
            TextField(text: $name) {
                Text(Localize.name())
            }
            .keyboardType(.URL)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            ClearTextButton(text: $name)
        }
    }
}
