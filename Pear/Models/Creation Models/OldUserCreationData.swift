//
//  GettingStartedUserData.swift
//  Pear
//
//  Created by Avery Lamp on 2/27/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import CoreLocation

class OldUserCreationData: CustomStringConvertible {
  
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
    if self.lastLocation == nil {
      print("get next input view controller... no last location")
      guard let locationVC = GetStartedLocationViewController.instantiate(gettingStartedUserData: self) else {
        print("Failed to create Location VC")
        return nil
      }
      return locationVC
    }
    
    if self.email == nil {
      guard let emailInputVC = GetStartedEmailProviderViewController.instantiate(gettingStartedUserData: self) else {
        print("Failed to create Email Provider VC")
        return nil
      }
      return emailInputVC
    }
    
    if self.firstName == nil {
      guard let userFirstNameVC = GetStartedUserFirstNameViewController.instantiate(gettingStartedUserData: self) else {
        print("Failed to start User First Name VC: ")
        return nil
      }
      return userFirstNameVC
    }
    
    if self.lastName == nil {
      guard let userLastNameVC = GetStartedUserLastNameViewController.instantiate(gettingStartedUserData: self) else {
        print("Failed to start User Last Name VC: ")
        return nil
      }
      return userLastNameVC
    }
    
    if self.age  == nil || self.birthdate  == nil {
      guard let birthdateVC = GetStartedBirthdateViewController.instantiate(gettingStartedUserData: self) else {
        print("Failed to start Birthdate VC")
        return nil
      }
      return birthdateVC
    }
    
    if self.gender == nil {
      guard let genderVC = GetStartedUserGenderViewController.instantiate(gettingStartedData: self) else {
        print("Failed to start Gender VC")
        return nil
      }
      return genderVC
    }
    
    if self.phoneNumber == nil {
      guard let phoneInputVC = GetStartedValidatePhoneNumberViewController.instantiate(gettingStartedUserData: self) else {
        print("Failed to create Phone Number VC")
        return nil
      }
      return phoneInputVC
    }
    
    return nil
  }
  
}
