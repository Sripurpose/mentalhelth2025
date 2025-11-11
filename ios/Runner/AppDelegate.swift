import UIKit
import Flutter
import GoogleMaps
import AVFoundation
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

    // ── App Group + keys (match your extension) ────────────────────────────────
    private let appGroupID   = "group.com.numuapp.numuapp"
    private let payloadKey   = "shared_payload"        // dictionary saved by extension
    private let hasDataKey   = "shared_hasData"        // Bool flag set by extension

    // Legacy (your previous flow)
    private let legacyJson   = "sharedData.json"       // file saved by extension
    private let legacyImageP = "sharedImage"           // sharedImage{i}.jpg

    // ── Flutter MethodChannel (MUST match your Dart code) ─────────────────────
    private let SHARE_CHANNEL = "numuapp.share"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Firebase / APNs / GMSServices: keep your existing setup
        FirebaseConfiguration.shared.setLoggerLevel(.debug) // set .min in prod
        FirebaseApp.configure()
        application.registerForRemoteNotifications()
        GeneratedPluginRegistrant.register(with: self)
        GMSServices.provideAPIKey("AIzaSyB_mUl0uBmISnObRAdQEF-Ffaa4mxq1LpQ")

        // Notifications permission (main app — correct place to ask)
        UNUserNotificationCenter.current().delegate = self
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        // Flutter method channel
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        let channel = FlutterMethodChannel(name: SHARE_CHANNEL, binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            switch call.method {
            case "getSharedData":
                self.getSharedData(result: result)

            case "clearSharedData":
                self.clearSharedData(result: result)

            case "checkForSharedContent", "hasSharedData":
                result(self.hasSharedData())

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // (Optional) If you set a flag in UserDefaults to indicate new data,
        // notify Flutter right away so your Dart can navigate.
        checkAndNotifyFlutterOfSharedContent(controller: controller)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ application: UIApplication,
                              didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("APNs token registered")
    }

    // Deep link from extension (e.g. numuapp://share) – notify Dart
    override func application(_ app: UIApplication,
                              open url: URL,
                              options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("🔗 Deep link received: \(url.absoluteString)")
        if url.scheme == "numuapp" && url.host == "share" {
            if let controller = window?.rootViewController as? FlutterViewController {
                let channel = FlutterMethodChannel(name: SHARE_CHANNEL, binaryMessenger: controller.binaryMessenger)
                channel.invokeMethod("onSharedContent", arguments: nil)
            }
        }
        return super.application(app, open: url, options: options)
    }

    // ── MARK: Share helpers ───────────────────────────────────────────────────

    private func checkAndNotifyFlutterOfSharedContent(controller: FlutterViewController) {
        let ud = UserDefaults(suiteName: appGroupID)
        let hasNewFlag = ud?.bool(forKey: "hasNewSharedContent") == true
        if hasNewFlag || hasSharedData() {
            print("✅ Found shared content on app launch")
            let channel = FlutterMethodChannel(name: SHARE_CHANNEL, binaryMessenger: controller.binaryMessenger)
            channel.invokeMethod("onSharedContent", arguments: nil)
        }
    }

    /// Unified flag: true if either UserDefaults payload exists OR legacy file exists.
    private func hasSharedData() -> Bool {
        if let ud = UserDefaults(suiteName: appGroupID),
           ud.bool(forKey: hasDataKey) == true {
            return true
        }
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return false
        }
        let fileURL = containerURL.appendingPathComponent(legacyJson)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    /// Returns a merged dictionary payload (adds imagePaths if using legacy files)
    private func readSharedDict() -> [String: Any]? {
        // 1) Preferred: UserDefaults payload
        if let ud = UserDefaults(suiteName: appGroupID),
           let dict = ud.object(forKey: payloadKey) as? [String: Any] {
            // If imagePaths missing, add from container using imageCount
            if dict["imagePaths"] == nil,
               let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID),
               let count = dict["imageCount"] as? Int, count > 0 {
                var merged = dict
                var paths: [String] = []
                for i in 0..<count {
                    let p = containerURL.appendingPathComponent("\(legacyImageP)\(i).jpg").path
                    if FileManager.default.fileExists(atPath: p) { paths.append(p) }
                }
                merged["imagePaths"] = paths
                return merged
            }
            return dict
        }

        // 2) Legacy: read sharedData.json and add imagePaths
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return nil
        }
        let fileURL = containerURL.appendingPathComponent(legacyJson)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }

        do {
            let data = try Data(contentsOf: fileURL)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard var dict = json as? [String: Any] else { return nil }

            // Build imagePaths if images were saved as sharedImage{i}.jpg
            var paths: [String] = []
            if let imageCount = dict["imageCount"] as? Int, imageCount > 0 {
                for i in 0..<imageCount {
                    let p = containerURL.appendingPathComponent("\(legacyImageP)\(i).jpg").path
                    if FileManager.default.fileExists(atPath: p) { paths.append(p) }
                }
            }
            dict["imagePaths"] = paths
            return dict
        } catch {
            print("❌ Error reading legacy sharedData.json: \(error)")
            return nil
        }
    }

    private func getSharedData(result: @escaping FlutterResult) {
        if let dict = readSharedDict() {
            print("✅ Returning shared data: \(dict)")
            result(dict) // Map to Dart
        } else {
            print("⚠️ No shared data available")
            result(nil)
        }
    }

    private func clearSharedData(result: @escaping FlutterResult) {
        var ok = true

        // Clear UserDefaults payload + flag
        if let ud = UserDefaults(suiteName: appGroupID) {
            ud.removeObject(forKey: payloadKey)
            ud.set(false, forKey: hasDataKey)
            // Your older keys:
            ud.removeObject(forKey: "hasNewSharedContent")
            ud.removeObject(forKey: "lastShareTimestamp")
            ud.synchronize()
        }

        // Remove legacy files if present
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            let fileURL = containerURL.appendingPathComponent(legacyJson)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do { try FileManager.default.removeItem(at: fileURL) } catch { ok = false }
            }
            if let contents = try? FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: nil) {
                contents.forEach { url in
                    if url.lastPathComponent.hasPrefix(legacyImageP) {
                        _ = try? FileManager.default.removeItem(at: url)
                    }
                }
            }
        }

        print("✅ Cleared shared data (ok=\(ok))")
        result(ok)
    }
}


