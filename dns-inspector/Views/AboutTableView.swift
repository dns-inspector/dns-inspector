import UIKit
import StoreKit
import MessageUI

// Apple hasn't yet updated the store and message UI SDKs to better work with SwiftUI. To avoid a mess of delegates and represted views, just
// break out the table view itself to UIKit.

class AboutTableView: UITableView, UITableViewDelegate, UITableViewDataSource, SKStoreProductViewControllerDelegate, MFMailComposeViewControllerDelegate {
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
            return "Share & Feedback"
        case 1:
            return "Get Involved"
        default:
            return ""
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Version \(AppInfo.version()) (build \(AppInfo.build()))"
        case 1:
            return "DNS Inspector is free & libre open source software licensed under the GNU GPLv3. DNS Inspector is copyright © 2023-2024 Ian Spence."
        default:
            return ""
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }

        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.imageView?.image = UIImage(systemName: "square.and.arrow.up.fill")
            cell.textLabel?.text = "Share DNS Inspector"
        case (0, 1):
            cell.imageView?.image = UIImage(systemName: "star.bubble.fill")
            cell.textLabel?.text = "Rate in App Store"
        case (0, 2):
            cell.imageView?.image = UIImage(systemName: "bubble.left.and.exclamationmark.bubble.right.fill")
            cell.textLabel?.text = "Provide Feedback"
        case (1, 0):
            cell.imageView?.image = UIImage(named: "Mastodon")
            cell.textLabel?.text = "Follow @dnsinspector on Mastodon"
        case (1, 1):
            cell.imageView?.image = UIImage(systemName: "apple.terminal.fill")
            cell.textLabel?.text = "Contribute to DNS Inspector"
        case (_, _): break
        }

        cell.imageView?.tintColor = UIColor(named: "Text")

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let activityController = UIActivityViewController(activityItems: ["Perform advanced DNS queries anytime & anywhere with DNS Inspector! https://dns-inspector.com"], applicationActivities: nil)
            ActionTipTarget(view: cell).attach(to: activityController.popoverPresentationController)
            // No idea if there's a better way of doing this
            self.window?.rootViewController?.presentedViewController?.present(activityController, animated: true)
            break
        case (0, 1):
            let productViewController = SKStoreProductViewController()
            productViewController.delegate = self
            let parameters = [
                SKStoreProductParameterITunesItemIdentifier: "1100539810",
                SKStoreProductParameterCampaignToken: "acid-burn",
            ]
            productViewController.loadProduct(withParameters: parameters, completionBlock: nil)
            self.window?.rootViewController?.presentedViewController?.present(productViewController, animated: true)
            break
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
            UIApplication.shared.open(URL(string: "https://github.com/dns-inspector/dns-inspector")!)
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
}
