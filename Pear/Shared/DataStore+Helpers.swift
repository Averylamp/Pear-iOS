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

extension DataStore {
  
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
  
}
