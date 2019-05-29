//
//  PearUserAPI+Helpers.swift
//  Pear
//
//  Created by Avery Lamp on 5/28/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Sentry
import CodableFirebase

// MARK: - General Helpers
extension PearUserAPI {

  func getCurrentUserID()throws  -> String {
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      throw UpdateUserAPIError.currentUserNotFound
    }
    return userID
  }
  
}

// MARK: - Create User Endpoint Helpers
extension PearUserAPI {
  
  func convertUserDataToQueryVariable(userData: OldUserCreationData) throws -> [String: Any] {
    guard
      let age = userData.age,
      let birthdate = userData.birthdate,
      let email = userData.email,
      let phoneNumber = userData.phoneNumber,
      let firstName = userData.firstName,
      let lastName = userData.lastName,
      let gender = userData.gender,
      let firebaseToken = userData.firebaseToken,
      let firebaseAuthID = userData.firebaseAuthID
      else {
        throw UserAPIError.invalidVariables
    }
    
    var variablesDictionary: [String: Any] = [
      "age": age,
      "email": email,
      "emailVerified": userData.emailVerified,
      "phoneNumber": phoneNumber,
      "phoneNumberVerified": userData.phoneNumberVerified,
      "firstName": firstName,
      "lastName": lastName,
      "gender": gender.rawValue,
      "firebaseToken": firebaseToken,
      "firebaseAuthID": firebaseAuthID
    ]
    
    if let firebaseRemoteInstanceID = userData.firebaseRemoteInstanceID {
      variablesDictionary["firebaseRemoteInstanceID"] = firebaseRemoteInstanceID
    }
    if let location = userData.lastLocation {
      variablesDictionary["location"] = [location.longitude, location.latitude]
    }
    let birthdayFormatter = DateFormatter()
    birthdayFormatter.dateFormat = "yyyy-MM-dd"
    variablesDictionary["birthdate"] = birthdayFormatter.string(from: birthdate)
    if let facebookId = userData.facebookId {
      variablesDictionary["facebookId"] = facebookId
    }
    if let facebookAccessToken = userData.facebookAccessToken {
      variablesDictionary["facebookAccessToken"] = facebookAccessToken
    }
    if let thumbnailURL = userData.thumbnailURL {
      variablesDictionary["thumbnailURL"] = thumbnailURL
    }
    return variablesDictionary
  }
}
