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

import Foundation

/// Class for getting meta information about the app
class AppInfo {
    /// Get the current version of the app
    static func version() -> String {
        return (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "Unknown"
    }

    /// Get the current build number of the app
    static func build() -> String {
        return (Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String) ?? "Unknown"
    }

    /// Get the bundle identifer of the app
    static func bundleName() -> String {
        return Bundle.main.bundleIdentifier ?? "Unknown"
    }
}
