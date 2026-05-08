
import SwiftUI
import FirebaseCore
import UIKit
import AppIntents
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    
    // Donate App Shortcuts so Siri phrases are available system-wide
    if #available(iOS 16.4, *) {
        StudyPalShortcuts.updateAppShortcutParameters()
    }

    // Request notification permission and set up the delegate
    NotificationManager.shared.requestAuthorization()

    return true
  }
}

@main
struct Study_PalApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @StateObject private var authViewModel = AuthViewModel()

  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
      .environmentObject(authViewModel)
    }
  }
}
