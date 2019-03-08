//
//  GettingStartedUserProfileData.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class GettingStartedUserProfileData: CustomStringConvertible {
  
  var firstName: String?
  var phoneNumber: String?
  var age: Int?
  var gender: GenderEnum?
  var interests: [String] = []
  var vibes: [String] = []
  var bio: String?
  var dos: [String] = []
  var donts: [String] = []
  var images: [GettingStartedUIImageContainer] = []
  
  init() {
    
  }
  
  var description: String {
    return "**** GettingStartedUserProfileData\n" + """
    profileFirstName: \(String(describing: firstName)),
    profilePhoneNumber: \(String(describing: phoneNumber)),
    profileGender: \(String(describing: gender)),
    profileAge: \(String(describing: age)),
    profileInterests: \(String(describing: interests)),
    profileVibes: \(String(describing: vibes)),
    profileBio: \(String(describing: bio)),
    profileDos: \(String(describing: dos)),
    profileDonts: \(String(describing: donts)),
    profileImages: \(String(describing: images)),
    """
    
  }
  
}
