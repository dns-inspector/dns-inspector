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
import DNSKit
import StoreKit
import MessageUI

// Apple hasn't yet updated the store and message UI SDKs to better work with SwiftUI. To avoid a mess of delegates and represted views, just
// break out the table view itself to UIKit.
@MainActor
class AboutTableView: UITableView, UITableViewDelegate, UITableViewDataSource, @preconcurrency SKStoreProductViewControllerDelegate, @preconcurrency MFMailComposeViewControllerDelegate {
    let dnsInspectorAppId = 6470965982
    let dnsInspectorAppStoreCampaignId = "crash-override"
    let tlsInspectorAppId = 1100539810
    let tlsInspectorAppStoreCampaignId = "crash-override"

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .insetGrouped)
        self.delegate = self
        self.dataSource = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return Localize.sharefeedback()
        case 1:
            return Localize.getinvolved()
        case 2:
            return Localize.morefromthedeveloper()
        case 3:
            return ""
        default:
            return ""
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return Localize.versionversionbuildbuild(version: AppInfo.version(), build: AppInfo.build())
        case 1:
            return Localize.aboutfooteryear(year: "2025")
        case 3:
            return "🏳️‍⚧️ Trans Rights!" // If this footer upsets or bothers you, I invite you to please fuck right off.
        default:
            return ""
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 3
        case 2:
            return 1
        case 3:
            return 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.imageView?.image = UIImage(systemName: "square.and.arrow.up.fill")
            cell.textLabel?.text = Localize.sharednsinspector()
        case (0, 1):
            cell.imageView?.image = UIImage(systemName: "star.bubble.fill")
            cell.textLabel?.text = Localize.rateinappstore()
        case (0, 2):
            cell.imageView?.image = UIImage(systemName: "bubble.left.and.exclamationmark.bubble.right.fill")
            cell.textLabel?.text = Localize.providefeedback()
        case (0, 3):
            cell.imageView?.image = UIImage(systemName: "ladybug.fill")
            cell.textLabel?.text = Localize.verboselogging()
            let toggle = UISwitch()
            toggle.isOn = LogWriter.shared.currentLevel() == .Debug
            toggle.addTarget(self, action: #selector(toggleVerboseLogging), for: .valueChanged)
            toggle.onTintColor = UIColor(named: "AccentColor")
            cell.accessoryView = toggle
        case (1, 0):
            cell.imageView?.image = UIImage(named: "Mastodon")
            cell.textLabel?.text = Localize.followdnsinspectoronmastodon()
        case (1, 1):
            cell.imageView?.image = UIImage(named: "Bluesky")
            cell.textLabel?.text = Localize.followdnsinspectorcomonbluesky()
        case (1, 2):
            cell.imageView?.image = UIImage(systemName: "terminal.fill")
            cell.textLabel?.text = Localize.contributetodnsinspector()
        case (2, 0):
            cell.imageView?.image = UIImage(named: "TLS Inspector Icon")
            cell.textLabel?.text = Localize.tlsinspector()
            cell.imageView?.clipsToBounds = true
            cell.imageView?.layer.cornerRadius = 7
        case (_, _): break
        }

        cell.textLabel?.numberOfLines = 0
        cell.imageView?.tintColor = UIColor(named: "Text")
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let activityController = UIActivityViewController(activityItems: ["Perform advanced DNS queries anytime & anywhere with DNS Inspector! https://dns-inspector.com"], applicationActivities: nil)
            ActionTipTarget(view: cell).attach(to: activityController.popoverPresentationController)
            self.present(activityController, animated: true)
        case (0, 1):
            self.showProductInAppStore(dnsInspectorAppId, campaignId: dnsInspectorAppStoreCampaignId)
        case (0, 2):
            if !MFMailComposeViewController.canSendMail() {
                UIApplication.shared.open(URL(string:"mailto:hello@dns-inspector.com?subject=DNS%20Inspector%20Feedback")!)
            } else {
                let mailController = MFMailComposeViewController()
                mailController.mailComposeDelegate = self
                mailController.setSubject("DNS Inspector Feedback")
                mailController.setToRecipients(["hello@dns-inspector.com"])

                let documentsDirectory = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
                let filePath = documentsDirectory.appendingPathComponent("DNSKit.log")
                do {
                    let data = try Data(contentsOf: filePath)
                    mailController.addAttachmentData(data, mimeType: "text/plain", fileName: "DNSKit.log")
                } catch {
                    print(error)
                }
                self.window?.rootViewController?.presentedViewController?.present(mailController, animated: true)
            }
        case (1, 0):
            UIApplication.shared.open(URL(string: "https://infosec.exchange/@dnsinspector")!)
        case (1, 1):
            UIApplication.shared.open(URL(string: "https://bsky.app/profile/dns-inspector.com")!)
        case (1, 2):
            UIApplication.shared.open(URL(string: "https://github.com/dns-inspector/dns-inspector")!)
        case (2, 0):
            self.showProductInAppStore(tlsInspectorAppId, campaignId: tlsInspectorAppStoreCampaignId)
        case (_, _): break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    func present(_ viewController: UIViewController, animated: Bool) {
        // Since this isn't a view controller but rather just a table view - we have to find the view controller that's hosting this view
        // I have no idea if there's a better way of doing this
        self.window?.rootViewController?.presentedViewController?.present(viewController, animated: true)
    }

    func showProductInAppStore(_ productId: Int, campaignId: String) {
        let productViewController = SKStoreProductViewController()
        productViewController.delegate = self
        let parameters = [
            SKStoreProductParameterITunesItemIdentifier: "\(productId)",
            SKStoreProductParameterCampaignToken: campaignId,
        ]
        productViewController.loadProduct(withParameters: parameters, completionBlock: nil)
        self.present(productViewController, animated: true)
    }

    @objc func toggleVerboseLogging(toggle: UISwitch) {
        LogWriter.shared.setLevel(toggle.isOn ? .Debug : LogWriter.defaultLogLevel())
    }
}
