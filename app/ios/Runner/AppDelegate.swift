import Flutter
import UIKit
import GoogleMaps
import flutter_sharing_intent
import awesome_notifications_fcm

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    SwiftAwesomeNotificationsFcmPlugin.setPluginRegistrantCallback { registry in
        GeneratedPluginRegistrant.register(with: registry)
    }
    
    GMSServices.provideAPIKey("AIzaSyCR-7VW7Kw81mtlGlhbnb7iumOzUeCYjpM")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // UIScene lifecycle support
  override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    let sharingIntent = SwiftFlutterSharingIntentPlugin.instance
    if sharingIntent.hasSameSchemePrefix(url: url) {
        return sharingIntent.application(app, open: url, options: options)
    }
    return super.application(app, open: url, options: options)
  }
}
