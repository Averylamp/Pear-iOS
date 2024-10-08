//
//  AppDelegate.swift
//  Pear
//
//  Created by Avery Lamp on 2/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Firebase
import Fabric
import Crashlytics
import Sentry
import FirebaseMessaging

@UIApplicationMain
final class AppDelegate: UIResponder {
  
  var window: UIWindow?
}

// MARK: - UIApplicationDelegate
extension AppDelegate: UIApplicationDelegate, MessagingDelegate {
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()
    Messaging.messaging().delegate = self

    Fabric.with([Crashlytics.self])
    
    do {
      Client.shared = try Client(dsn: "https://8383e222e5e946cf8017740102da428e@sentry.io/1423458")
      try Client.shared?.startCrashHandler()
      Client.shared?.trackMemoryPressureAsEvent()
    } catch let error {
      print("\(error)")
    }
    
    #if DEVMODE
    if CommandLine.arguments.contains("--uitesting") {
      resetState()
    }
    Analytics.setAnalyticsCollectionEnabled(false)
//    resetState()
    #endif
    #if PROD
    Analytics.setAnalyticsCollectionEnabled(true)
    #endif

    self.stylize()
    
    window = UIWindow(frame: UIScreen.main.bounds)
    guard let navController = LandingNavigationViewController.instantiate() else {
      fatalError("Something went horribly wrong")
    }
    window?.rootViewController = navController
    window?.makeKeyAndVisible()
    
    // register for remote notifications if we have notification authorization
    DataStore.shared.registerForRemoteNotificationsIfAuthorized()
    return true
  }
  
  func stylize() {
    UITabBar.appearance().tintColor = UIColor(red: 0.27, green: 0.29, blue: 0.33, alpha: 1.00)
    
  }
  
  func resetState() {
    let defaultsName = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: defaultsName)
    do {
      try Auth.auth().signOut()
    } catch {
      print("Failed Firebase Auth")
    }
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return application(app, open: url,
                       sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                       annotation: "")
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    print("Application will resign active")
    SlackHelper.shared.sendStory()
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    print("Application will terminate")
  }
  
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
      // Handle the deep link. For example, show the deep-linked content or
      // apply a promotional offer to the user's account.
      // ...
      
      self.handleDynamicLink(url: dynamicLink.url)
      
      return true
    }
    return false
  }
  
  func application(_ application: UIApplication,
                   continue userActivity: NSUserActivity,
                   restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (link, error) in
      if let error = error {
        print(error)
      }
      if let link = link {
        self.handleDynamicLink(url: link.url)
      }
    }
    
    return handled
  }
  
  func handleDynamicLink(url: URL?) {
    print("DYNAMIC LINK FOUND: \(url)")
    if let urlString = url?.absoluteString,
      let refIndex = urlString.endIndex(of: "ref=") {
      
      let referalCode = String(urlString.suffix(from: refIndex))
      SlackHelper.shared.addEvent(text: "User entered with referal code: \(referalCode)", color: UIColor.green)
      print(referalCode)
      DataStore.shared.saveStringToDefaults(string: referalCode, flag: .lastDynamicLinkCode)
    }
    print("Finished dynamic link")
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
    if UIApplication.shared.applicationIconBadgeNumber < 100 {
      UIApplication.shared.applicationIconBadgeNumber += 1
    }
    if Auth.auth().canHandleNotification(notification) {
      print(notification)
      completionHandler(.noData)
      return
    }
    // This notification is not auth related, developer should handle it.
  }
  
}

// implement the firebase messaging delegate protocol
extension AppDelegate {
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    InstanceID.instanceID().instanceID { (result, error) in
      if let error = error {
        print("Error fetching remote instance ID: \(error)")
      } else if let result = result {
        print("Remote instance ID token: \(result.token)")
        DataStore.shared.firebaseRemoteInstanceID = result.token
        // [Brian] hmm usually by this point we haven't actually retrieved the pear user, so this will no-op
        DataStore.shared.updateLatestLocationAndToken()
      }
    }
  }
  
}
