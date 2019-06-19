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
  
  func refreshEvents(completion: (([PearEvent]) -> Void)?) {
    self.fetchUIDToken { (result) in
      switch result {
      case .success(let authTokens):
        PearEventAPI.shared.getEventsForUser(uid: authTokens.uid, token: authTokens.token, completion: { (result) in
          switch result {
          case .success(let events):
            print("Fetched events")
            self.userEvents = events
            if let completion = completion {
              completion(events)
            }
          case .failure(let error):
            print("Failure getting events: \(error)")
          }
        })
      case .failure(let error):
        print("Failure getting auth tokens: \(error)")
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
  
  func reloadAllUserData(completion: (() -> Void)?) {
    DispatchQueue.global(qos: .userInitiated).async {
      print("reloading user data")
      DataStore.shared.refreshMatchRequests { (matchRequests) in
        print("Found Match Requests: \(matchRequests.count)")
      }
      DataStore.shared.refreshCurrentMatches { (matches) in
        print("Found Current Matches: \(matches.count)")
      }
      
      let refreshGroup = DispatchGroup()
      refreshGroup.enter()
      DataStore.shared.refreshEndorsedUsers { (_, _) in
        print("refreshed endorsed users")
        refreshGroup.leave()
      }
      refreshGroup.enter()
      DataStore.shared.refreshEvents { (events) in
        print("Found events for this user: \(events.count)")
        refreshGroup.leave()
      }
      refreshGroup.wait()
      if let completion = completion {
        completion()
      }
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
