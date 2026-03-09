import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var screenProtectionView: UIView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as? FlutterViewController

    if let controller = controller {
      let channel = FlutterMethodChannel(
        name: "com.company.app/screen",
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] (call, result) in
        switch call.method {
        case "enableProtection":
          self?.enableScreenProtection()
          result(nil)
        case "disableProtection":
          self?.disableScreenProtection()
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // MARK: - Screen Protection

  /// Uses a secure UITextField trick to prevent screenshots and screen recording.
  /// When isSecureTextEntry is set on a text field added to the window,
  /// iOS hides the window content in screenshots, recordings, and AirPlay.
  private func enableScreenProtection() {
    guard screenProtectionView == nil, let window = window else { return }

    let field = UITextField()
    field.isSecureTextEntry = true
    field.isUserInteractionEnabled = false

    let protectionView = UIView(frame: window.bounds)
    protectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    if let layer = field.layer.sublayers?.first {
      layer.frame = protectionView.bounds
      protectionView.layer.addSublayer(layer)
    }

    window.addSubview(protectionView)
    screenProtectionView = protectionView
  }

  private func disableScreenProtection() {
    screenProtectionView?.removeFromSuperview()
    screenProtectionView = nil
  }
}
