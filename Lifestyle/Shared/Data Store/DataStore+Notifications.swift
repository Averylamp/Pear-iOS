//
//  DataStore+Notifications.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

extension DataStore {
  
  func getNotificationAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      completion(settings.authorizationStatus)
    }
  }
  
  func registerForRemoteNotificationsIfAuthorized() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      guard settings.authorizationStatus == .authorized else { return }
      print("Registering for remote notifications")
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }
  
}
