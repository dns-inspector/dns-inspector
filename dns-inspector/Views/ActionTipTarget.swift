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

import UIKit

@MainActor
class ActionTipTarget {
    private var view: UIView?
    private var barButtonItem: UIBarButtonItem?

    init(view: UIView) {
        self.view = view
    }

    init(barButtonItem: UIBarButtonItem) {
        self.barButtonItem = barButtonItem
    }

    public func attach(to: UIPopoverPresentationController?) {
        if let view = self.view {
            to?.sourceView = view
        } else if let barButtonItem = self.barButtonItem {
            to?.barButtonItem = barButtonItem
        }
    }
}
