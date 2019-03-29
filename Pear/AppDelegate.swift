//
//  AppDelegate.swift
//  SubtleAsianMatches
//
//  Created by Kelvin Lau on 2018-12-26.
//  Copyright © 2018 sam. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import Fabric
import Crashlytics
import Sentry

@UIApplicationMain
final class AppDelegate: UIResponder {
  
  var window: UIWindow?
}

// MARK: - UIApplicationDelegate
extension AppDelegate: UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()
    
    //    Forces Remote config fetch
    Fabric.with([Crashlytics.self])
    
    do {
      Client.shared = try Client(dsn: "https://8383e222e5e946cf8017740102da428e@sentry.io/1423458")
      try Client.shared?.startCrashHandler()
      Client.shared?.trackMemoryPressureAsEvent()
      
    } catch let error {
      print("\(error)")
    }
    
    SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    if CommandLine.arguments.contains("--uitesting") {
      resetState()
    }
    
    window = UIWindow(frame: UIScreen.main.bounds)
    let navController = LandingNavigationViewController.instantiate()
    window?.rootViewController = navController
    //        window?.rootViewController = GetStartedPhotoInputViewController.instantiate(gettingStartedData: GetttingStartedData.fakeData())
    window?.makeKeyAndVisible()
    return true
  }
  
  func resetState() {
    let defaultsName = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: defaultsName)
    do {
      try Auth.auth().signOut()
    } catch {
      print("Failed Firebase Auth")
    }
    LoginManager().logOut()
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return SDKApplicationDelegate.shared.application(app, open: url, options: options)
  }
  
}

extension AppDelegate {
  
  // Called when APNs has assigned the device a unique token
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Convert token to string
    let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
    print("APNs device token: \(deviceTokenString)")
    
    Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
  }
  
  // Called when APNs failed to register the device for push notifications
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    // Print the error to console (you should alert the user that registration failed)
    print("APNs registration failed: \(error)")
  }
  
  func application(_ application: UIApplication,
                   didReceiveRemoteNotification notification: [AnyHashable: Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("Received Remote Notification: \(notification)")
    if Auth.auth().canHandleNotification(notification) {
      print(notification)
      completionHandler(.noData)
      return
    }
    // This notification is not auth related, developer should handle it.
  }
  
}
