//
//  Profile.swift
//  SubtleAsianMatches
//
//  Created by Avery on 1/6/19.
//  Copyright © 2019 sam. All rights reserved.
//

import Foundation
import MapKit

class Profile{
    
    let active: Bool
    let age: Int
    let documentId: String
    let endorsed: Bool
    let ethnicities: Array<String>
    let gender: String
    let locationCoordinate: CLLocationCoordinate2D
    let profileFirstName: String
    let profileLastName: String
    
    
    init(){
        self.active = false
        self.age = 0
        self.documentId = ""
        self.endorsed = false
        self.ethnicities = []
        self.gender = ""
        self.locationCoordinate = CLLocationCoordinate2DMake(0, 0)
        self.profileFirstName = ""
        self.profileLastName = ""
    }
    
    init(active: Bool,
         age: Int,
         documentId: String,
         endorsed: Bool,
         ethnicities: Array<String>,
         gender: String,
         locationCoordinate: CLLocationCoordinate2D,
         profileFirstName: String,
         profileLastName: String){
        self.active = active
        self.age = age
        self.documentId = documentId
        self.endorsed = endorsed
        self.ethnicities = ethnicities
        self.gender = gender
        self.locationCoordinate = locationCoordinate
        self.profileFirstName = profileFirstName
        self.profileLastName = profileLastName
    }
    
    convenience init?(dictionary: [String: Any?]) {
        guard
            let active = dictionary[ProfileKeys.active] as? Bool,
            let age = dictionary[ProfileKeys.age] as? Int,
            let documentId = dictionary[ProfileKeys.documentId] as? String,
            let endorsed = dictionary[ProfileKeys.endorsed] as? Bool,
            let ethnicities = dictionary[ProfileKeys.ethnicities] as? Array<String>,
            let gender = dictionary[ProfileKeys.gender] as? String,
            let locationCoordinate = dictionary[ProfileKeys.locationCoordinate] as? CLLocationCoordinate2D,
            let profileFirstName = dictionary[ProfileKeys.profileFirstName] as? String,
            let profileLastName = dictionary[ProfileKeys.profileLastName] as? String
        else{
            return nil
        }
        self.init(active: active, age: age, documentId: documentId, endorsed: endorsed, ethnicities: ethnicities, gender: gender, locationCoordinate: locationCoordinate, profileFirstName: profileFirstName, profileLastName: profileLastName)
    }
    
    class func initFakeProfile() -> Profile{
        let fakeData: [String: Any?] = [
            ProfileKeys.age: 20,
            ProfileKeys.active: true,
            ProfileKeys.documentId: "FakeID",
            ProfileKeys.endorsed: false,
            ProfileKeys.ethnicities: ["White", "Korean"],
            ProfileKeys.gender: "Male",
            ProfileKeys.locationCoordinate: CLLocationCoordinate2DMake(0, 0),
            ProfileKeys.profileFirstName: "Avery",
            ProfileKeys.profileLastName: "Lamp"
        ]
        
        
        return Profile(dictionary: fakeData)!
    }
    
}


