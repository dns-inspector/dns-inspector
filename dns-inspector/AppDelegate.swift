import UIKit
import DNSKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UserOptions.load()
        DNSKit.log = LogWriter.shared

        LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] App loaded")

        NSSetUncaughtExceptionHandler { exc in
            LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Uncaught exception: \(exc.name) \(exc.reason ?? "no reason") \(exc.callStackSymbols.joined(separator: "\\n"))")
            LogWriter.shared.close()
        }

        return true
    }
}
