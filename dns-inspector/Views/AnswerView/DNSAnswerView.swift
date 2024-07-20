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

struct DNSAnswerView: View {
    let answer: Answer

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(answer.name)
                    .font(Font.body.bold().smallCaps())
            }
            .padding(8.0)
            .frame(maxWidth: .infinity)
            .background(Color("LightBackground", bundle: nil))
            DNSAnswerDataView(answer: answer, onCopyRecord: copyAnswer)
                .padding(.horizontal)
                .padding(.vertical, 8.0)
            HStack {
                Spacer()
                Text(answer.recordType.string())
                    .font(Font.body.smallCaps())
                    .padding(.vertical, 8.0)
                Spacer()
                Divider()
                Spacer()
                Text(answer.recordClass.string())
                    .font(Font.body.smallCaps())
                    .padding(.vertical, 8.0)
                Spacer()
                Divider()
                Spacer()
                switch UserOptions.ttlDisplayMode {
                case .absolute:
                    Text("\(answer.ttlSeconds) seconds")
                        .font(Font.body.smallCaps())
                        .padding(.vertical, 8.0)
                case .relative:
                    Text(self.relativeTtlString())
                        .font(Font.body.smallCaps())
                        .padding(.vertical, 8.0)
                }
                Spacer()
            }
            .overlay(Divider(), alignment: .top)
        }
        .frame(maxWidth: .infinity)
        .listRowInsets(EdgeInsets())
    }

    func copyAnswer() {
        UIPasteboard.general.string = answer.description
    }

    func relativeTtlString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        let duration = TimeInterval(integerLiteral: Int64(answer.ttlSeconds))
        return formatter.localizedString(fromTimeInterval: duration)
    }
}
