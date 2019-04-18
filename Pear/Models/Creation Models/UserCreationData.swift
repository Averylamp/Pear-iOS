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

class UserCreationData: CustomStringConvertible {
  
  var firstName: String?
  var lastName: String?
  var email: String?
  var emailVerified: Bool = false
  var age: Int?
  var gender: GenderEnum?
  var birthdate: Date?
  var phoneNumber: String?
  var phoneNumberVerified: Bool = false
  var primaryAuth: AuthCredential?
  var firebaseToken: String?
  var firebaseAuthID: String?
  var facebookId: String?
  var facebookAccessToken: String?
  var thumbnailURL: String?
  var lastLocation: CLLocationCoordinate2D?
  var firebaseRemoteInstanceID: String?
  init() {
    
  }
  
  var description: String {
    return "**** GettingStartedUserData\n " + """
    firstName: \(String(describing: firstName)),
    lastName: \(String(describing: lastName)),
    email: \(String(describing: email)),
    emailVerified: \(String(describing: emailVerified)),
    age: \(String(describing: age)),
    gender: \(String(describing: gender)),
    birthdate: \(String(describing: birthdate)),
    phoneNumber: \(String(describing: phoneNumber)),
    phoneNumberVerified: \(String(describing: phoneNumberVerified)),
    firebaseToken: \(String(describing: firebaseToken)),
    firebaseAuthID: \(String(describing: firebaseAuthID)),
    facebookId: \(String(describing: facebookId)),
    facebookAccessToken: \(String(describing: facebookAccessToken)),
    """
  }
  
  func getNextInputViewController() -> UIViewController? {
    
    return nil
  }
  
}
