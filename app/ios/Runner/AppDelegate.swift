import Flutter
import UIKit
import GoogleMaps
import flutter_sharing_intent

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyCR-7VW7Kw81mtlGlhbnb7iumOzUeCYjpM")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    let sharingIntent = SwiftFlutterSharingIntentPlugin.instance
    if sharingIntent.hasSameSchemePrefix(url: url) {
        return sharingIntent.application(app, open: url, options: options)
    }
    return super.application(app, open: url, options: options)
  }
}
