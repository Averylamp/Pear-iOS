//
//  MatchedPearUser.swift
//  Pear
//
//  Created by Avery Lamp on 3/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

class MatchedPearUser: Decodable, CustomStringConvertible {
  
  var documentID: String
  var firstName: String
  var lastName: String
  var fullName: String
  var thumbnailURL: String?
  var gender: String?
  var locationName: String?
  var locationCoordinates: String?
  var school: String?
  var birthdate: Date?
  var age: Int
  var userProfiles: [PearUserProfile] = []
  
  static let graphQLMatchedUserFields: String = "{ _id deactivated firstName lastName fullName thumbnailURL gender school birthdate age profileObjs \(PearUserProfile.graphQLUserProfileFields) displayedImages \(ImageContainer.graphQLImageFields) matchingPreferences { seekingGender } pearPoints }"
  
  init() {
    fatalError("Should never be called to generate")
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: PearUserKeys.self)
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.firstName = try values.decode(String.self, forKey: .firstName)
    self.lastName = try values.decode(String.self, forKey: .lastName)
    self.fullName = try values.decode(String.self, forKey: .fullName)
    self.thumbnailURL = try? values.decode(String.self, forKey: .thumbnailURL)
    self.gender = try? values.decode(String.self, forKey: .gender)
    self.locationName = try? values.decode(String.self, forKey: .locationName)
    self.locationCoordinates = try? values.decode(String.self, forKey: .locationCoordinates)
    self.school = try? values.decode(String.self, forKey: .school)
    let birthdateValue = try? values.decode(String.self, forKey: .birthdate)
    if let birthdateValue = birthdateValue, let birthdateNumberValue = Double(birthdateValue) {
      self.birthdate = Date(timeIntervalSince1970: birthdateNumberValue / 1000)
    }
    self.age = try values.decode(Int.self, forKey: .age)
    
    self.userProfiles = try values.decode([PearUserProfile].self, forKey: .profileObjs)
  }
  
  var description: String {
    return "**** Pear User **** \n" + """
    documentID: \(String(describing: documentID)),
    firstName: \(String(describing: firstName)),
    lastName: \(String(describing: lastName)),
    fullName: \(String(describing: fullName)),
    thumbnailURL: \(String(describing: thumbnailURL)),
    gender: \(String(describing: gender)),
    locationName: \(String(describing: locationName)),
    locationCoordinates: \(String(describing: locationCoordinates)),
    school: \(String(describing: school)),
    birthdate: \(String(describing: birthdate)),
    age: \(String(describing: age)),
    \(self.userProfiles.count) User Profiles Found,
    """
  }
}
