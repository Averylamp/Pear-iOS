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
import SwiftyJSON

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
      } else if deviceVersionArr.count == 2 {
        if deviceVersionArr[1] > minMajor && deviceVersionArr[0] > minVersion ||
          deviceVersionArr[0] > minVersion {
          completion(true)
        } else {
          completion(true)
        }
      }
    } else {
      completion(true)
    }
  }
  
  func hasCompletedSetup() -> Bool {
    if DataStore.shared.currentPearUser?.gender != nil,
      DataStore.shared.currentPearUser?.birthdate != nil,
      let images = DataStore.shared.currentPearUser?.displayedImages,
      let isSeeking = DataStore.shared.currentPearUser?.isSeeking,
      (images.count > 0 || !isSeeking) {
      return true
    }
    return false
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
      currentUser.getIDTokenForcingRefresh(true) { (token, error) in
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
  
  func refreshPearUser(completion: ((PearUser?) -> Void)?) {
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
                                      DataStore.shared.reloadAllUserData()
                                      Crashlytics.sharedInstance().setUserEmail(pearUser.email)
                                      Crashlytics.sharedInstance().setUserIdentifier(pearUser.firebaseAuthID)
                                      Crashlytics.sharedInstance().setUserName(pearUser.fullName)
                                      Client.shared?.extra = [
                                        "email": pearUser.email ?? "",
                                        "phoneNumber": pearUser.phoneNumber ?? "",
                                        "firebaseAuthID": pearUser.firebaseAuthID!,
                                        "fullName": pearUser.fullName ?? "",
                                        "userDocumentID": pearUser.documentID!
                                      ]
                                      trace?.incrementMetric("Existing User Found", by: 1)
                                      trace?.stop()
                                      DataStore.shared.updateLatestLocationAndToken()
                                      if let completion = completion {
                                        completion(pearUser)
                                      }
                                      return
                                    case .failure(let error):
                                      print("Error getting Pear User: \(error)")
                                      trace?.incrementMetric("No Existing User Found", by: 1)
                                      trace?.stop()
                                      if let completion = completion {
                                        completion(nil)
                                      }
                                      return
                                    }
        })
      case .failure(let error):
        print("Could not find existing tokens: \(error)")
        if let completion = completion {
          completion(nil)
        }
        return
      }
    }
  }
  
  func refreshCurrentMatches(matchRequestsFound: (([Match]) -> Void)?) {
    self.fetchUIDToken { (result) in
      switch result {
      case .success(let authTokens):
        PearMatchesAPI.shared.getMatchesForUser(uid: authTokens.uid,
                                                token: authTokens.token,
                                                matchType: .currentMatches,
                                                completion: { (result) in
                                                  switch result {
                                                  case .success(let matches):
                                                    self.currentMatches = matches
                                                    print("Current Matches:\(self.matchRequests.count)")
                                                    NotificationCenter.default.post(name: .refreshChatsTab, object: nil)
                                                    if let matchCompletion = matchRequestsFound {
                                                      matchCompletion(matches)
                                                    }
                                                  case .failure(let error):
                                                    print("Failure getting error: \(error)")
                                                    if let matchCompletion = matchRequestsFound {
                                                      matchCompletion([])
                                                    }
                                                  }
        })
      case .failure(let error):
        print("Failure getting Tokens: \(error)")
        if let matchCompletion = matchRequestsFound {
          matchCompletion([])
        }
        return
      }
    }
  }
  
  func refreshMatchRequests(matchRequestsFound: (([Match]) -> Void)?) {
    self.fetchUIDToken { (result) in
      switch result {
      case .success(let authTokens):
        PearMatchesAPI.shared.getMatchesForUser(uid: authTokens.uid,
                                                token: authTokens.token,
                                                matchType: .matchRequests,
                                                completion: { (result) in
                                                  switch result {
                                                  case .success(let matches):
                                                    self.matchRequests = matches
                                                    print("Match Requests:\(self.matchRequests.count)")
                                                    NotificationCenter.default.post(name: .refreshChatsTab, object: nil)
                                                    if let matchCompletion = matchRequestsFound {
                                                      matchCompletion(matches)
                                                    }
                                                  case .failure(let error):
                                                    print("Failure getting error: \(error)")
                                                    if let matchCompletion = matchRequestsFound {
                                                      matchCompletion([])
                                                    }
                                                  }
        })
      case .failure(let error):
        print("Failure getting Tokens: \(error)")
        if let matchCompletion = matchRequestsFound {
          matchCompletion([])
        }
        return
      }
    }
  }
  
  func updateLatestLocationAndToken() {
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Unable to update locaiton or token for not logged in user")
      return
    }
    
    var updates: [String: Any] = [:]
    if let remoteInstanceID = DataStore.shared.firebaseRemoteInstanceID {
      updates["firebaseRemoteInstanceID"] = remoteInstanceID
    }
    if let lastLocation = DataStore.shared.lastLocation {
      var coordinates: [Double] = []
      coordinates.append(lastLocation.longitude)
      coordinates.append(lastLocation.latitude)
      updates["location"] = coordinates
      
    }
    PearUserAPI.shared.updateUser(userID: userID, updates: updates) { (result) in
      switch result {
      case .success(let successful):
        if successful {
          print("Updated User Location and Firebase Remote Instance ID")
          print(updates)
        } else {
          print("** Unsuccessful User Locaiton and Remote ID Update \n\(updates)")
        }
      case .failure(let error):
        print("** Unsuccessful User Locaiton and Remote ID Update \n\(updates)\nerror:\(error)")
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
  
  func refreshEndorsedUsers(completion: ((_ endorsedUsers: [PearUser], _ detachedProfiles: [PearDetachedProfile]) -> Void)?) {
    self.fetchUIDToken { (result) in
      switch result {
      case .success(let authTokens):
        PearUserAPI.shared.fetchEndorsedUsers(uid: authTokens.uid,
                                              token: authTokens.token,
                                              completion: { (result) in
                                                switch result {
                                                case .success(let (newEndorsedUsers, newDetachedProfiles)):
                                                  print("Fetched Endorsed and Detached Profiles")
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
  
  func hasUpdatedPreferences() -> Bool {
    // we should do something more robust in the future, but for now just check if the settings are defaults
    if let user = DataStore.shared.currentPearUser {
      if user.matchingPreferences.seekingGender.count != 3 {
        return true
      }
      if user.matchingPreferences.minAgeRange != 18 {
        return true
      }
      if user.matchingPreferences.maxAgeRange != 40 && user.matchingPreferences.maxAgeRange != 24 {
        return true
      }
    }
    return false
  }
  
  func reloadAllUserData() {
    DataStore.shared.refreshEndorsedUsers(completion: nil)
    DataStore.shared.refreshMatchRequests { (matchRequests) in
      print("Found Match Requests: \(matchRequests.count)")
    }
    DataStore.shared.refreshCurrentMatches { (matches) in
      print("Found Current Matches: \(matches.count)")
    }
  }
  
  func reloadPossibleQuestions() {
    PearContentAPI.shared.getQuestions { (result) in
      switch result {
      case .success(let questions):
        print("\(questions.count) Questions Found")
        self.possibleQuestions = questions
      case .failure(let error):
        print("Error retrieving questions:\(error)")
      }
    }
  }
  
  func getWaitlistNumber(completion: @escaping (Int) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    
    request.allHTTPHeaderFields = [
      "Content-Type": "application/json"
    ]
    do {
      let fullDictionary: [String: Any] = [
        "query": "query { getUserCount }"
      ]
      
      guard let data: Data = try? JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted) else {
        print("Failed to serialize request")
        return
      }
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          return
        }
        if let data = data,
          let json = try? JSON(data: data),
          let userCount = json["data"]["getUserCount"].int {
          print("Waitlist number \(userCount)")
          completion(userCount)
        }
      }
      dataTask.resume()
    }
    
  }
  
}
