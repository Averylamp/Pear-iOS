//
//  UserCreationData.swift
//  Pear
//
//  Created by Avery Lamp on 4/18/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import CoreLocation

enum UserCreationDataError: Error {
  case missingRequiredFields
}

class UserCreationData: CustomStringConvertible {
  
  var phoneNumber: String?
  var phoneNumberVerified: Bool = false
  var firebaseAuthID: String?
  var firebaseRemoteInstanceID: String?
  var referredByCode: String?
  init() {
    
  }
  
  var description: String {
    return "**** GettingStartedUserData\n " + """
    phoneNumber: \(String(describing: phoneNumber)),
    phoneNumberVerified: \(String(describing: phoneNumberVerified)),
    firebaseAuthID: \(String(describing: firebaseAuthID)),
    referedByCode: \(String(describing: referredByCode)),
    """
  }

  func toGraphQLInput()throws -> [String: Any] {
    guard let phoneNumber = self.phoneNumber,
      let firebaseAuthID = self.firebaseAuthID else {
        print("Missing required Fields")
        throw UserCreationDataError.missingRequiredFields
    }
    var input: [String: Any] = [
      "phoneNumber": phoneNumber,
      "phoneNumberVerified": phoneNumberVerified,
      "firebaseAuthID": firebaseAuthID
    ]

    if let remoteInstanceID = self.firebaseRemoteInstanceID {
      input["firebaseRemoteInstanceID"] = remoteInstanceID
    }
    if let referredCode = self.referredByCode {
      input["referredByCode"] = referredCode
    }
    return input
  }
  
}
