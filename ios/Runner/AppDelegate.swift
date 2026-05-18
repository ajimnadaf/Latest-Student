import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    private let CHANNEL = "device_id_channel"
    private let OPEN_CHANNEL = "open_file_channel"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

        // =========================
        // Device ID Channel
        // =========================
        let deviceChannel = FlutterMethodChannel(
            name: CHANNEL,
            binaryMessenger: controller.binaryMessenger
        )

        deviceChannel.setMethodCallHandler { call, result in
            if call.method == "getDeviceUniqueId" {
                // iOS equivalent of Android ID (identifierForVendor)
                if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
                    result(deviceId)
                } else {
                    result(FlutterError(code: "UNAVAILABLE",
                                        message: "Device ID not available",
                                        details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        // =========================
        // Open File / URL Channel
        // =========================
        let openChannel = FlutterMethodChannel(
            name: OPEN_CHANNEL,
            binaryMessenger: controller.binaryMessenger
        )

        openChannel.setMethodCallHandler { call, result in
            if call.method == "openFileOrUrl" {

                guard let args = call.arguments as? [String: Any],
                      let path = args["path"] as? String else {
                    result(FlutterError(code: "INVALID",
                                        message: "Invalid arguments",
                                        details: nil))
                    return
                }

                self.openFileOrUrl(path: path, result: result)

            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // ===============================
    // Open URL or File
    // ===============================
    private func openFileOrUrl(path: String, result: @escaping FlutterResult) {

        // 🌐 URL
        if path.starts(with: "http") {
            if let url = URL(string: path) {
                UIApplication.shared.open(url)
                result(true)
            } else {
                result(FlutterError(code: "INVALID_URL", message: "URL is invalid", details: nil))
            }
            return
        }

        // 📁 Local File
        let fileURL = URL(fileURLWithPath: path)

        if FileManager.default.fileExists(atPath: fileURL.path) {

            let docController = UIDocumentInteractionController(url: fileURL)
            docController.delegate = self

            DispatchQueue.main.async {
                if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                    docController.presentPreview(animated: true)
                }
            }

            result(true)

        } else {
            result(FlutterError(code: "FILE_NOT_FOUND", message: "File does not exist", details: nil))
        }
    }
}

// ===============================
// Document Preview Delegate
// ===============================
extension AppDelegate: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(
        _ controller: UIDocumentInteractionController
    ) -> UIViewController {
        return UIApplication.shared.windows.first!.rootViewController!
    }
}
