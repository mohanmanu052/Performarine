import UIKit
import Flutter
import flutter_background_service_ios
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
  SwiftFlutterBackgroundServicePlugin.taskIdentifier = SwiftFlutterBackgroundServicePlugin.taskIdentifier

  FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }

  if #available(iOS 10.0, *) {
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
  }
    GeneratedPluginRegistrant.register(with: self)
    return
    super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
