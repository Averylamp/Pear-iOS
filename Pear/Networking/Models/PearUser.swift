//
//  PearUser.swift
//  Pear
//
//  Created by Avery Lamp on 2019-3-4.
//  Copyright © 2019 Pear. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

class PearUser: Codable, CustomStringConvertible {
  
  var documentID: String
  var deactivated: Bool
  var firebaseToken: String
  var firebaseAuthID: String
  var facebookId: String?
  var facebookAccessToken: String?
  var email: String
  var emailVerified: Bool
  var phoneNumber: String
  var phoneNumberVerified: Bool
  var firstName: String
  var lastName: String
  var fullName: String
  var thumbnailURL: String?
  var gender: String?
  var locationName: String?
  var locationCoordinates: String?
  var school: String?
  var schoolEmail: String?
  var schoolEmailVerified: String?
  var birthdate: Date?
  var age: Int
  var userProfiles: [PearUserProfile] = []
  var displayedImages: [ImageContainer] = []
  
  static let graphQLUserFields: String = "{ _id deactivated firebaseToken firebaseAuthID facebookId facebookAccessToken email emailVerified phoneNumber phoneNumberVerified firstName lastName fullName thumbnailURL gender locationName locationCoordinates school schoolEmail schoolEmailVerified birthdate age profile_ids profileObjs \(PearUserProfile.graphQLUserProfileFields) displayedImages \(ImageContainer.graphQLImageFields) endorsedProfile_ids matchingPreferences { seekingGender } userStats { totalNumberOfMatches totalNumberOfMatches } matchingDemographics { ethnicities } userMatches_id discoveryQueue_id pearPoints }"
  
  init() {
    fatalError("Should never be called to generate")
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: PearUserKeys.self)
    print(values)
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.deactivated = try values.decode(Bool.self, forKey: .deactivated)
    self.firebaseToken = try values.decode(String.self, forKey: .firebaseToken)
    self.firebaseAuthID = try values.decode(String.self, forKey: .firebaseAuthID)
    self.facebookId = try? values.decode(String.self, forKey: .facebookId)
    self.facebookAccessToken = try? values.decode(String.self, forKey: .facebookAccessToken)
    self.email = try values.decode(String.self, forKey: .email)
    self.emailVerified = try values.decode(Bool.self, forKey: .emailVerified)
    self.phoneNumber = try values.decode(String.self, forKey: .phoneNumber)
    self.phoneNumberVerified = try values.decode(Bool.self, forKey: .phoneNumberVerified)
    self.firstName = try values.decode(String.self, forKey: .firstName)
    self.lastName = try values.decode(String.self, forKey: .lastName)
    self.fullName = try values.decode(String.self, forKey: .fullName)
    self.thumbnailURL = try? values.decode(String.self, forKey: .thumbnailURL)
    self.gender = try? values.decode(String.self, forKey: .gender)
    self.locationName = try? values.decode(String.self, forKey: .locationName)
    self.locationCoordinates = try? values.decode(String.self, forKey: .locationCoordinates)
    self.school = try? values.decode(String.self, forKey: .school)
    self.schoolEmail = try? values.decode(String.self, forKey: .schoolEmail)
    self.schoolEmailVerified = try? values.decode(String.self, forKey: .schoolEmailVerified)
    let birthdateValue = try? values.decode(String.self, forKey: .birthdate)
    if let birthdateValue = birthdateValue, let birthdateNumberValue = Double(birthdateValue) {
      self.birthdate = Date(timeIntervalSince1970: birthdateNumberValue / 1000)
    }
    self.age = try values.decode(Int.self, forKey: .age)
    let profiles = try values.decode([PearUserProfile].self, forKey: .profileObjs)
    self.userProfiles = profiles
    let images = try values.decode([ImageContainer].self, forKey: .displayedImages)
    self.displayedImages = images
    
  }
  
  var description: String {
    return "**** Pear User **** \n" + """
    documentID: \(String(describing: documentID)),
    deactivated: \(String(describing: deactivated)),
    firebaseToken: \(String(describing: firebaseToken)),
    firebaseAuthID: \(String(describing: firebaseAuthID)),
    facebookId: \(String(describing: facebookId)),
    facebookAccessToken: \(String(describing: facebookAccessToken)),
    email: \(String(describing: email)),
    emailVerified: \(String(describing: emailVerified)),
    phoneNumber: \(String(describing: phoneNumber)),
    phoneNumberVerified: \(String(describing: phoneNumberVerified)),
    firstName: \(String(describing: firstName)),
    lastName: \(String(describing: lastName)),
    fullName: \(String(describing: fullName)),
    thumbnailURL: \(String(describing: thumbnailURL)),
    gender: \(String(describing: gender)),
    locationName: \(String(describing: locationName)),
    locationCoordinates: \(String(describing: locationCoordinates)),
    school: \(String(describing: school)),
    schoolEmail: \(String(describing: schoolEmail)),
    schoolEmailVerified: \(String(describing: schoolEmailVerified)),
    birthdate: \(String(describing: birthdate)),
    age: \(String(describing: age)),
    """
  }
}
