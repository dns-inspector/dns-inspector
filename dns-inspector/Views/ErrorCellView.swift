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

public struct ErrorCellView: View {
    public let error: String
    public let title: String

    public init(error: Error, title: String = "Error") {
        self.error = localizedErrorDetails(error)
        self.title = title
    }

    public init(error: String, title: String = "Error") {
        self.error = error
        self.title = title
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
                Text(self.title).bold()
            }
            Text(error)
        }
    }
}

#Preview {
    ErrorCellView(error: NSError(domain: "com.example", code: -1, userInfo: [NSLocalizedDescriptionKey: "Hello, world!"]))
}
