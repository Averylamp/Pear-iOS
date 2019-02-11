//
//  Endorsement.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class Endorsement {
    
    var endorseeName: String?
    var name: String?
    var age: Int?
    var interests: [String] = []
    var userEmail: String?
    var userPhoneNumber: String?
    init(){
        
    }
 
    class func fakeUser()->Endorsement{
        let endorsement = Endorsement()
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
