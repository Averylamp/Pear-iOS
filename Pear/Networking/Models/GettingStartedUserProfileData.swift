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
  
  func fakePopulate() {
    self.firstName = "Avery"
    self.age = 21
    self.gender = .male
    self.interests = ["Sports", "Coding", "Environment", "Tech"]
    self.vibes = ["forbidden fruit", "coco-nuts"]
    // swiftlint:disable:next line_length
    self.bio = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    self.dos = ["take him to eat ramen", "feed him tasty food", "take him to the movies"]
    self.donts = ["feed him vegetables", "make him sleep on time"]
    
  }
  
}
