//
//  Endorsement.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetttingStartedData {
    
    var profileData = ProfileData()
    var userFullName: String?
    var userFirstName: String?
    var userLastName: String?
    var userEmail: String?
    var userPhoneNumber: String?
    
    init(){
        
    }
    
    
 
    class func fakeData()->GetttingStartedData{
        let data = GetttingStartedData()
        data.profileData = ProfileData.fakeProfile()
        data.userFirstName = data.profileData.endorsedFirstName
        data.userLastName = data.profileData.endorsedLastName
        data.userFullName = data.profileData.endorsedFullName
        data.userEmail = "fakeemail@gmail.com"
        data.userPhoneNumber = "+1 1234567890"
        return data
    }
    
}
