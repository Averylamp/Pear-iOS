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
  
  struct AuthenticationTokens {
    let uid: String
    let token: String
  }
  
  func fetchUIDToken(completion: @escaping (Result<AuthenticationTokens, UserAPIError>) -> Void) {
    let trace = Performance.startTrace(name: "Fetching Firebase Token")
    if let currentUser = Auth.auth().currentUser {
      let uid = currentUser.uid
      currentUser.getIDToken { (token, error) in
        if let error = error {
          print("Error getting firebase token: \(error)")
          trace?.incrementMetric("Firebase Token Error", by: 1)
          trace?.stop()
          completion(.failure(UserAPIError.unauthenticated))
          return
        }
        if let token = token {
          trace?.stop()
          completion(.success(AuthenticationTokens(uid: uid, token: token)))
          return
        } else {
          trace?.stop()
          completion(.failure(UserAPIError.unauthenticated))
          return
        }
      }
    } else {
      completion(.failure(UserAPIError.unauthenticated))
    }
    
  }
  
  func fetchExistingUser(pearUserFoundCompletion:(() -> Void)?, userNotFoundCompletion: (() -> Void)?) {
    self.fetchUIDToken { (result) in
      switch result {
      case .success(let authTokens):
        let trace = Performance.startTrace(name: "Loading Screen Existing User")
        PearUserAPI.shared.getUser(uid: authTokens.uid,
                                   token: authTokens.token,
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
              if let pearFoundCompletion = pearUserFoundCompletion {
                pearFoundCompletion()
              }
              return
            case .failure(let error):
              print("Error getting Pear User: \(error)")
              trace?.incrementMetric("No Existing User Found", by: 1)
              trace?.stop()
              if let pearNotFoundCompletion = userNotFoundCompletion {
                pearNotFoundCompletion()
              }
              return
            }
        })
      case .failure(let error):
        print("Failure getting Tokens: \(error)")
        if let pearNotFoundCompletion = userNotFoundCompletion {
          pearNotFoundCompletion()
        }
        return
      }
    }
  }
  
  func fetchMatchRequests(matchRequestsFound: (([Match]) -> Void)?) {
    self.fetchUIDToken { (result) in
      switch result {
      case .success(let authTokens):
        PearMatchesAPI.shared.getMatchesForUser(uid: authTokens.uid,
                                                token: authTokens.token,
                                                completion: { (result) in
            switch result {
            case .success(let matches):
              self.matchRequests = matches
              if let matchCompletion = matchRequestsFound {
                matchCompletion(matches)
              }
            case .failure(let error):
              print("Failure getting error: \(error)")
            }
        })
      case .failure(let error):
        print("Failure getting Tokens: \(error)")
        return
      }
    }
  }
  
  func checkForDetachedProfiles(detachedProfilesFound: @escaping ([PearDetachedProfile]) -> Void) {
    if let user = DataStore.shared.currentPearUser {
      PearProfileAPI.shared.checkDetachedProfiles(phoneNumber: user.phoneNumber) { (result) in
        switch result {
        case .success(let detachedProfiles):
          detachedProfilesFound(detachedProfiles)
          return
        case .failure(let error):
          print("Error checking for Detached Profiles: \(error)")
          detachedProfilesFound([])
          return
        }
      }
    } else {
      detachedProfilesFound([])
      return
    }
  }
  
  func refreshEndorsedUsers(completion: ((_ endorsedUsers: [MatchingPearUser], _ detachedProfiles: [PearDetachedProfile]) -> Void)?) {
    self.fetchUIDToken { (result) in
      switch result {
      case .success(let authTokens):
        PearUserAPI.shared.fetchEndorsedUsers(uid: authTokens.uid,
                                              token: authTokens.token,
                                              completion: { (result) in
            switch result {
            case .success(let (newEndorsedUsers, newDetachedProfiles)):
              self.endorsedUsers = newEndorsedUsers
              self.detachedProfiles  =  newDetachedProfiles
              if let completion = completion {
                completion(newEndorsedUsers, newDetachedProfiles)
              }
            case .failure(let error):
              print("Failure getting endorsed users: \(error)")
            }
        })
      case .failure(let error):
        print("Failure getting auth tokens: \(error)")
      }
    }
    
  }
  
  func getNotificationAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      print("Notification settings: \(settings)")
      completion(settings.authorizationStatus)
    }
  }
  
  func registerForRemoteNotificationsIfAuthorized() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      print("Notification settings: \(settings)")
      guard settings.authorizationStatus == .authorized else { return }
      print("registering for remote notifications")
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }
  
}
