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
import FirebaseAuth
import Fabric
import Crashlytics

@UIApplicationMain
final class AppDelegate: UIResponder {
  
  var window: UIWindow?
}

// MARK: - UIApplicationDelegate
extension AppDelegate: UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    let navController = LandingNavigationViewController.instantiate()
    window?.rootViewController = navController
    //        window?.rootViewController = GetStartedPhotoInputViewController.instantiate(gettingStartedData: GetttingStartedData.fakeData())
    window?.makeKeyAndVisible()
    FirebaseApp.configure()
    
//    Forces Remote config fetch
    print(DataStore.shared.remoteConfig.configSettings)
    Fabric.with([Crashlytics.self])

    SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    return true
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
