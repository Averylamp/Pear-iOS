//
//  Endorsement.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GettingStartedUserProfileData {
    
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
    
}
