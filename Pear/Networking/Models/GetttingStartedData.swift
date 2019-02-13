//
//  Endorsement.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetttingStartedData {
    
    var endorseeName: String?
    var name: String?
    var age: Int?
    var interests: [String] = []
    var shortBio: String?
    var userEmail: String?
    var userPhoneNumber: String?
    var doList: [String] = []
    var dontList: [String] = []
    var images: [UIImage] = []
    
    init(){
        
    }
 
    class func fakeUser()->GetttingStartedData{
        let endorsement = GetttingStartedData()
        endorsement.name = "John Smith"
        endorsement.endorseeName = "Jane Doe"
        endorsement.age = 22
        endorsement.interests = [
            "Adventure",
            "Storytelling",
            "News",
            "Technology",
            "Music",
            "Movies",
        ]
        
        return endorsement
    }
    
}
