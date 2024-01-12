import UIKit
import DNSKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UserOptions.load()

        NSSetUncaughtExceptionHandler { exc in
            LogWriter.sharedInstance().writeError("Uncaught exception: \(exc.name) \(exc.reason ?? "no reason") \(exc.callStackSymbols.joined(separator: "\\n"))")
            LogWriter.sharedInstance().close()
        }

        return true
    }
}
