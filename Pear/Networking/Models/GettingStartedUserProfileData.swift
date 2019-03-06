//
//  Endorsement.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GettingStartedUserProfileData: CustomStringConvertible {
    
    var profileFirstName: String?
    var profilePhoneNumber: String?
    var phoneNumberVerified: Bool = false
    var profileGender: GenderEnum?
    var profileAge: Int?
    var profileInterests: [String] = []
    var profileVibes: [String] = []
    var profileBio: String?
    var profileDos: [String] = []
    var profileDonts: [String] = []
    var profileImages: [GettingStartedUIImage] = []
    
    init() {
        
    }
    
    var description: String {
        return "**** GettingStartedUserProfileData\n" + """
        profileFirstName: \(String(describing: profileFirstName)),
        profilePhoneNumber: \(String(describing: profilePhoneNumber)),
        phoneNumberVerified: \(String(describing: phoneNumberVerified)),
        profileGender: \(String(describing: profileGender)),
        profileAge: \(String(describing: profileAge)),
        profileInterests: \(String(describing: profileInterests)),
        profileVibes: \(String(describing: profileVibes)),
        profileBio: \(String(describing: profileBio)),
        profileDos: \(String(describing: profileDos)),
        profileDonts: \(String(describing: profileDonts)),
        profileImages: \(String(describing: profileImages)),
        """
        
    }
    
}
