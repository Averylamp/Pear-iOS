//
//  DataStore+Helpers.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebasePerformance
import Crashlytics
import Sentry
import UserNotifications

extension DataStore {
  
  func getVersionNumber(versionSufficientCompletion: @escaping (Bool) -> Void) {
    if let lastFetchTime = self.remoteConfig.lastFetchTime,
      lastFetchTime > Date(timeIntervalSinceNow: -12 * 60 * 60) {
      self.compareVersionNumber(completion: versionSufficientCompletion)
    } else {
      self.reloadRemoteConfig { (reloadedCompletion) in
        if reloadedCompletion {
          print("Reloaded Remote Config")
          self.compareVersionNumber(completion: versionSufficientCompletion)
        } else {
          versionSufficientCompletion(true)
        }
      }
    }
  }
  
  func compareVersionNumber(completion: @escaping(Bool) -> Void) {
    if let minVersion = self.remoteConfig.configValue(forKey: "min_version").numberValue?.intValue,
      let minMajor = self.remoteConfig.configValue(forKey: "min_major").numberValue?.intValue,
      let minMinor = self.remoteConfig.configValue(forKey: "min_minor").numberValue?.intValue,
      let deviceVersionStr = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
      let deviceVersionArr = deviceVersionStr.components(separatedBy: ".").compactMap({Int($0)})
      if deviceVersionArr.count == 3 {
        completion(compareVersionArrays(a: deviceVersionArr, b: [minVersion, minMajor, minMinor]))
      } else {
        completion(true)
      }
    } else {
      completion(true)
    }
  }
  
  // is a at least b
  // swiftlint:disable identifier_name
  func compareVersionArrays(a: [Int], b: [Int]) -> Bool {
    for i in 0..<min(a.count, b.count) where a[i] != b[i] {
      return a[i] > b[i]
    }
    return true
  }
  // swiftlint:enable identifier_name
  
  func checkForExistingUser(pearUserFoundCompletion: @escaping () -> Void, userNotFoundCompletion: @escaping () -> Void) {
    let trace = Performance.startTrace(name: "Loading Screen Existing User")
    if let currentUser = Auth.auth().currentUser {
      let uid = currentUser.uid
      currentUser.getIDToken { (token, error) in
        if let error = error {
          print("Error getting firebase token: \(error)")
          trace?.incrementMetric("Firebase Token Error", by: 1)
          trace?.stop()
          userNotFoundCompletion()
          return
        }
        if let token = token {
          trace?.incrementMetric("Firebase Token Found", by: 1)
          PearUserAPI.shared.getUser(uid: uid,
                                     token: token,
                                     completion: { (result) in
              switch result {
              case .success(let pearUser):
                print("Got Existing Pear User \(String(describing: pearUser))")
                DataStore.shared.currentPearUser = pearUser
                
                Crashlytics.sharedInstance().setUserEmail(pearUser.email)
                Crashlytics.sharedInstance().setUserIdentifier(pearUser.firebaseAuthID)
                Crashlytics.sharedInstance().setUserName(pearUser.fullName)
                Client.shared?.extra = [
                  "email": pearUser.email!,
                  "firebaseAuthID": pearUser.firebaseAuthID!,
                  "fullName": pearUser.fullName!,
                  "userDocumentID": pearUser.documentID!
                ]
                trace?.incrementMetric("Existing User Found", by: 1)
                trace?.stop()
                pearUserFoundCompletion()
                return
              case .failure(let error):
                print("Error getting Pear User: \(error)")
                trace?.incrementMetric("No Existing User Found", by: 1)
                trace?.stop()
                userNotFoundCompletion()
                return
              }
          })
        } else {
          trace?.incrementMetric("Firebase Token Not Found", by: 1)
          trace?.stop()
          print("No token found")
          userNotFoundCompletion()
        }
      }
    } else {
      trace?.incrementMetric("Current Firebase User Not Found", by: 1)
      trace?.stop()
      userNotFoundCompletion()
    }
  }
  
  func checkForDetachedProfiles(detachedProfilesFound: @escaping ([PearDetachedProfile]) -> Void, detachedProfilesNotFound: @escaping () -> Void) {
    if let user = DataStore.shared.currentPearUser {
      PearProfileAPI.shared.checkDetachedProfiles(phoneNumber: user.phoneNumber) { (result) in
        switch result {
        case .success(let detachedProfiles):
          print(detachedProfiles)
          detachedProfilesFound(detachedProfiles)
          return
        case .failure(let error):
          print("Error checking for Detached Profiles: \(error)")
          detachedProfilesNotFound()
          return
        }
      }
    } else {
      detachedProfilesNotFound()
      return
    }
  }
  
  func checkForNotificationsEnabled(completion: @escaping  (Bool) -> Void) {
    if #available(iOS 12, *) {
      UNUserNotificationCenter.current()
        .requestAuthorization(
        options: [.badge, .alert, .sound, .provisional, .providesAppNotificationSettings, .criticalAlert]) { (result, error) in
          DispatchQueue.main.sync {
            UIApplication.shared.registerForRemoteNotifications()
            if let error = error {
              print(error)
            }
            completion(result)
          }
      }
      
    } else if #available(iOS 11, *) {
      UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (result, error) in
        DispatchQueue.main.sync {
          UIApplication.shared.registerForRemoteNotifications()
          if let error = error {
            print(error)
          }
          completion(result)
        }
      }
    }
    
  }
  
}
