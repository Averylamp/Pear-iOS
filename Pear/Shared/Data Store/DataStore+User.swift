//
//  DataStore+User.swift
//  Pear
//
//  Created by Avery Lamp on 6/19/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import FirebasePerformance
import Crashlytics
import Sentry
import SwiftyJSON

// MARK: - User Functions
extension DataStore {
  
  /// Refreshes the Current Pear user and reloads all user data
  ///
  /// - Parameter completion: Optional completion for when the user has refreshed
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
                                      DataStore.shared.currentPearUser = pearUser
                                      do {
                                        if let userData = UserDefaults.standard.data(forKey: UserDefaultKeys.cachedPearUser.rawValue) {
                                          if let json = try? JSON(data: userData) {
                                             print(json)
                                          }
                                          let cachedUser = try JSONDecoder().decode(PearUser.self, from: userData)
                                          print(cachedUser)
                                        }
                                        let encodedUser = try JSONEncoder().encode(pearUser)
                                        UserDefaults.standard.set(encodedUser, forKey: UserDefaultKeys.cachedPearUser.rawValue)
                                        
                                      } catch {
                                        print("Error: \(error)")
                                      }
                                      DataStore.shared.reloadAllUserData {
                                        print("reloaded all user data")
                                        Crashlytics.sharedInstance().setUserEmail(pearUser.email)
                                        Crashlytics.sharedInstance().setUserIdentifier(pearUser.firebaseAuthID)
                                        Crashlytics.sharedInstance().setUserName(pearUser.fullName())
                                        Client.shared?.extra = [
                                          "email": pearUser.email ?? "",
                                          "phoneNumber": pearUser.phoneNumber ?? "",
                                          "firebaseAuthID": pearUser.firebaseAuthID!,
                                          "fullName": pearUser.fullName(),
                                          "userDocumentID": pearUser.documentID!
                                        ]
                                        trace?.incrementMetric("Existing User Found", by: 1)
                                        trace?.stop()
                                        DataStore.shared.updateLatestLocationAndToken()
                                        if let completion = completion {
                                          completion(pearUser)
                                        }
                                        return
                                      }
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
  
  /// Updates the User's location and Notification Token in the database if fetchable
  func updateLatestLocationAndToken() {
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Unable to update locaiton or token for not logged in user")
      return
    }
    
    var updates: [String: Any] = [:]
    if let remoteInstanceID = DataStore.shared.firebaseRemoteInstanceID {
      updates["firebaseRemoteInstanceID"] = remoteInstanceID
    }
    if let lastLocation = DataStore.shared.locationManager.location?.coordinate {
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

}
