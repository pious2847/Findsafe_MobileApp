import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Read Google Maps API key from environment or use a default
    // Note: In production, this should come from a secure configuration
    let googleMapsApiKey = ProcessInfo.processInfo.environment["GOOGLE_API_KEY"] ?? "AIzaSyDfR0xgwZw5Dblp0A7O1VPFX9BEXZ0oefY"
    GMSServices.provideAPIKey(googleMapsApiKey)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
