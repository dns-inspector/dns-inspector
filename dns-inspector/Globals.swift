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

import Foundation

let presetServerChangedNotification = Notification.Name(rawValue: "preset.server.changed")

/// Create an error object with the given localized description.
/// - Parameter description: The localized description value
/// - Returns: An error object. The error code will be -1.
func MakeError(_ description: String) -> Error {
    return MakeError(description, code: -1)
}

/// Create an error object with the given localized description and code.
/// - Parameters:
///   - description: The localized description value
///   - code: The error code.
/// - Returns: An error object.
func MakeError(_ description: String, code: Int) -> Error {
    return NSError(domain: "io.ecn.dns-inspector", code: -1, userInfo: [NSLocalizedDescriptionKey: description])
}
