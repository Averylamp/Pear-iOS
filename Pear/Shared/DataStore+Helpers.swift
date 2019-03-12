//
//  DataStore+Helpers.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import FirebaseAuth

extension DataStore {
  
  func checkForExistingUser(pearUserFoundCompletion: @escaping () -> Void, userNotFoundCompletion: @escaping () -> Void) {
    if let currentUser = Auth.auth().currentUser {
      let uid = currentUser.uid
      currentUser.getIDToken { (token, error) in
        if let error = error {
          print("Error getting token: \(error)")
          userNotFoundCompletion()
          return
        }
        if let token = token {
          PearUserAPI.shared.getUser(uid: uid,
                                     token: token,
                                     completion: { (result) in
              switch result {
              case .success(let pearUser):
                print("Got Existing Pear User \(String(describing: pearUser))")
                DataStore.shared.currentPearUser = pearUser
                pearUserFoundCompletion()
              case .failure(let error):
                print("Error getting Pear User: \(error)")
                userNotFoundCompletion()
              }
          })
          
        } else {
          print("No token found")
          userNotFoundCompletion()
        }
      }
    } else {
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
