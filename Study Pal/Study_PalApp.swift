//
//  Study_PalApp.swift
//  Study Pal
//
//  Created by Mohamed Shafran on 2026-03-30.
//

import SwiftUI
// import FirebaseCore // Uncomment when Firebase is installed

// class AppDelegate: NSObject, UIApplicationDelegate {
//     func application(_ application: UIApplication,
//                      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//         FirebaseApp.configure()
//         return true
//     }
// }

@main
struct Study_PalApp: App {
    // @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
