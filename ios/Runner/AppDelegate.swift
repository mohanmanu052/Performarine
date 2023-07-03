import UIKit
import Flutter
import flutter_local_notifications
// import flutter_background_service_ios
import FirebaseCore
import path_provider_foundation
import background_locator_2

func registerPlugins(registry: FlutterPluginRegistry) {
    GeneratedPluginRegistrant.register(with: registry)
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
  // SwiftFlutterBackgroundServicePlugin.taskIdentifier = "com.performarine.ios.app.refresh"
  BackgroundLocatorPlugin.setPluginRegistrantCallback(registerPlugins)

  registerOtherPlugins()

  FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }

  if #available(iOS 10.0, *) {
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
  }


    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func registerOtherPlugins() {
          if !hasPlugin("io.flutter.plugins.pathprovider") {
              PathProviderPlugin
                  .register(with: registrar(forPlugin: "io.flutter.plugins.pathprovider")!)
          }
      }
}
