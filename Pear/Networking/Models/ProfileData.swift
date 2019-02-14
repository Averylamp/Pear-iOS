//
//  ProfileData.swift
//  Pear
//
//  Created by Avery Lamp on 2/13/19.
//  Copyright © 2019 sam. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ProfileData {
    
    var firstName: String
    var lastName: String
    var fullName: String
    var endorsedName: String? = nil
    var age: Int
    var interests: [String]
    var shortBio: String
    var doList: [String]
    var dontList: [String]
    var imageURLs: [URL]
    var images: [UIImage]
    var locationData: LocationData? = nil
    var schoolName: String? = nil
    var work: WorkData? = nil
    
    
    
    init(){
        firstName = ""
        lastName = ""
        fullName = ""
        endorsedName = ""
        age = 0
        interests = []
        shortBio = ""
        doList = []
        dontList = []
        imageURLs = []
        images = []
        
    }
    
    init (  firstName: String,
            lastName: String,
            fullName: String,
            endorsedName: String?,
            age: Int,
            interests: [String],
            shortBio: String,
            doList: [String],
            dontList: [String],
            imageURLs: [URL],
            images: [UIImage],
            locationData: LocationData? = nil,
            schoolName: String? = nil,
            workData: WorkData? = nil){
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName
        self.endorsedName = endorsedName
        self.age = age
        self.interests = interests
        self.shortBio = shortBio
        self.doList = doList
        self.dontList = dontList
        self.imageURLs = imageURLs
        self.images = images
        self.locationData = locationData
        self.schoolName = schoolName
        self.work = workData
    }
    
    
    class func fakeProfile()->ProfileData{
        
        let firstName = "Jacob"
        let lastName =  "Smith"
        let fullName =  "Jacob Smith"
        let endorsedName = "Avery"
        let age = 19
        let interests = ["Cars", "Technology", "Coding", "Pizza", "Pasta"]
        let shortBio = """
        Start your engines ladies. This gent’s on the prowl. 🐈

        Great guy with a great heart (latest bp 113/74). He’s a transplant (now living in Boston). Heart is not a transplant.
        """
        let doList = ["take him to the movies", "ask about his family. They are super close and his parents are hilarious. He is just like his dad.", "be weird - Jacob seems normal but he's far from it."]
        let dontList = ["be a dud.  Make a joke or something." , "talk to him about sports, especially not basketball (unless you have nothing to do for the next hour)"]
        let imageURLs: [URL] = []
        let images: [UIImage] = [UIImage(named: "sample-profile-jacob-1")!, UIImage(named: "sample-profile-jacob-2")!, UIImage(named: "sample-profile-jacob-3")!]
        
        return ProfileData( firstName: firstName,
                            lastName: lastName,
                            fullName: fullName,
                            endorsedName: endorsedName,
                            age: age,
                            interests: interests,
                            shortBio: shortBio,
                            doList: doList,
                            dontList: dontList,
                            imageURLs: imageURLs,
                            images: images)
    }
    
    
}


class WorkData {
    let workCompany: String
    let workPosition: String
    
    init(workCompany: String,
         workPosition: String) {
        self.workCompany = workCompany
        self.workPosition = workPosition
    }
}

class LocationData {
    let locationString: String
    let locationCoordinate: CLLocationCoordinate2D
    
    init(   locationString: String,
            locationCoordinate: CLLocationCoordinate2D){
        self.locationString = locationString
        self.locationCoordinate = locationCoordinate
    }
}
