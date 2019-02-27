//
//  Endorsement.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GettingStartedData {
    
    var profileData = ProfileData()
    var userFullName: String?
    var userFirstName: String?
    var userLastName: String?
    var userEmail: String?
    var userPhoneNumber: String?
    var phoneNumberVerified: Bool = false
    init(){
        
    }
    
    
 
    class func fakeData()->GettingStartedData{
        let data = GettingStartedData()
        data.profileData = FakeProfileData.listOfFakeProfiles().randomElement()!
        data.userFirstName = data.profileData.endorsedFirstName
        data.userLastName = data.profileData.endorsedLastName
        data.userFullName = data.profileData.endorsedFullName
        data.userEmail = "fakeemail@gmail.com"
        data.userPhoneNumber = "+1 1234567890"
        return data
    }
    
}
