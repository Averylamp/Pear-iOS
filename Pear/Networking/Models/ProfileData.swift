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
    var endorsedFullName: String? = nil
    var endorsedFirstName: String? = nil
    var endorsedLastName: String? = nil
    var age: Int
    var interests: [String]
    var shortBio: String
    var doList: [String]
    var dontList: [String]
    var imageURLs: [URL]
    var images: [UIImage]
    var phoneNumber: String
    var locationData: LocationData? = nil
    var schoolName: String? = nil
    var work: WorkData? = nil
    
    
    
    init(){
        firstName = ""
        lastName = ""
        fullName = ""
        endorsedFullName = ""
        age = 0
        interests = []
        shortBio = ""
        doList = []
        dontList = []
        imageURLs = []
        images = []
        phoneNumber = ""
    }
    
    init (  firstName: String,
            lastName: String,
            fullName: String,
            endorsedFullName: String?,
            age: Int,
            interests: [String],
            shortBio: String,
            doList: [String],
            dontList: [String],
            imageURLs: [URL],
            images: [UIImage],
            phoneNumber: String,
            locationData: LocationData? = nil,
            schoolName: String? = nil,
            workData: WorkData? = nil){
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName
        self.endorsedFullName = endorsedFullName
        if let endorsedFullName = self.endorsedFullName{
            let splitNames = endorsedFullName.splitIntoFirstLastName()
            self.endorsedFirstName = splitNames.0
            if splitNames.1.count > 0{
                self.endorsedLastName = splitNames.1
            }
        }
        self.age = age
        self.interests = interests
        self.shortBio = shortBio
        self.doList = doList
        self.dontList = dontList
        self.imageURLs = imageURLs
        self.images = images
        self.phoneNumber = phoneNumber
        self.locationData = locationData
        self.schoolName = schoolName
        self.work = workData
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


class FakeProfileData{
    
    class func listOfFakeProfiles()-> [ProfileData]{
        return [FakeProfileData.fakeProfileJacob(),
                FakeProfileData.fakeProfileCory(),
                FakeProfileData.fakeProfileErika(),
                FakeProfileData.fakeProfileLexi(),
                FakeProfileData.fakeProfileShane(),
                FakeProfileData.fakeProfileBrooke()]
    }
    
    class func fakeProfileJacob()->ProfileData{
        
        let firstName = "Jacob"
        let lastName =  "Smith"
        let fullName =  "Jacob Smith"
        let endorsedName = "Avery Lamp"
        let age = 23
        let interests = ["Cars", "Technology", "Coding", "Pizza", "Pasta"]
        let shortBio = """
        Start your engines ladies. This gent’s on the prowl. 🐈

        Great guy with a great heart (latest bp 113/74). He’s a transplant (now living in Boston). Heart is not a transplant.
        """
        let doList = ["take him to the movies", "ask about his family. They are super close and his parents are hilarious. He is just like his dad.", "be weird - Jacob seems normal but he's far from it."]
        let dontList = ["be a dud.  Make a joke or something." , "talk to him about sports, especially not basketball (unless you have nothing to do for the next hour)"]
        let imageURLs: [URL] = []
        let images: [UIImage] = [UIImage(named: "sample-profile-jacob-1")!, UIImage(named: "sample-profile-jacob-2")!, UIImage(named: "sample-profile-jacob-3")!]
        let phoneNumber = "1234567890"
        return ProfileData( firstName: firstName,
                            lastName: lastName,
                            fullName: fullName,
                            endorsedFullName: endorsedName,
                            age: age,
                            interests: interests,
                            shortBio: shortBio,
                            doList: doList,
                            dontList: dontList,
                            imageURLs: imageURLs,
                            images: images,
                            phoneNumber: phoneNumber)
    }
    
    class func fakeProfileCory()->ProfileData{
        
        let firstName =  "Cory"
        let lastName =  "Westbrook"
        let fullName =  "Cory Westbrook"
        let endorsedName = "Avery Lamp"
        let age =  22
        let interests =  ["Music", "Knitting", "Cars"]
        let shortBio =  "WARNING: this man will steal your heart if you aren’t careful. :) He’s a genius musician who can play 6 instruments, but he won’t play you."
        let doList =  ["ask him what he’s making right now. He always has a new project."]
        let dontList =  ["feed him peanuts - he’s allergic."]
        let images: [UIImage] =  [UIImage(named: "sample-profile-cory-1")!, UIImage(named: "sample-profile-cory-2")!]
        let imageURLs: [URL] = []
        let phoneNumber = "1234567890"
        return ProfileData( firstName: firstName,
                            lastName: lastName,
                            fullName: fullName,
                            endorsedFullName: endorsedName,
                            age: age,
                            interests: interests,
                            shortBio: shortBio,
                            doList: doList,
                            dontList: dontList,
                            imageURLs: imageURLs,
                            images: images,
                            phoneNumber: phoneNumber)
    }
    
    class func fakeProfileErika()->ProfileData {
        let firstName = "Erika"
        let lastName = "Green"
        let fullName = "Erika Green"
        let endorsedName = "Avery Lamp"
        let age = 24
        let interests = ["Sailing", "Design", "Hiking"]
        let shortBio = "Your dream has come to life, and her name is Erika Green. You’ll never be bored if you join her adventures. She’s always having fun :P"
        let doList = ["take her to a dog park. The more puppies, the better."]
        let dontList = ["cut off her coffee supply. Or talk to her before she’s had at least two cups."]
        let images: [UIImage] = [UIImage(named: "sample-profile-erika-1")!, UIImage(named: "sample-profile-erika-2")!, UIImage(named: "sample-profile-erika-3")!, UIImage(named: "sample-profile-erika-4")!]
        let imageURLs: [URL] = []
        let phoneNumber = "1234567890"
        return ProfileData( firstName: firstName,
                            lastName: lastName,
                            fullName: fullName,
                            endorsedFullName: endorsedName,
                            age: age,
                            interests: interests,
                            shortBio: shortBio,
                            doList: doList,
                            dontList: dontList,
                            imageURLs: imageURLs,
                            images: images,
                            phoneNumber: phoneNumber)
    }
    
    class func fakeProfileLexi()->ProfileData {
        let firstName =  "Lexi"
        let lastName =  "Amaya"
        let fullName =  "Lexi Amaya"
        let age =  20
        let interests =  ["Dance", "Cooking", "Photography"]
        let shortBio =  "Don’t let her RBF fool you. This is this nicest, most bubbly girl you will ever meet. Also, she speaks FIVE languages?!?! :0 Time to cuff her up NOW."
        let doList =  ["go on a photoshoot with her. She’ll know how to get allll your angles."]
        let dontList =  ["meet her family unless you’re for real because she has four older brothers who are obsessed with her."]
        let images: [UIImage] =  [UIImage(named: "sample-profile-lexi-1")!, UIImage(named: "sample-profile-lexi-2")!, UIImage(named: "sample-profile-lexi-3")!]
        let endorsedName = "Avery Lamp"
        let imageURLs: [URL] = []
        let phoneNumber = "1234567890"
        return ProfileData( firstName: firstName,
                            lastName: lastName,
                            fullName: fullName,
                            endorsedFullName: endorsedName,
                            age: age,
                            interests: interests,
                            shortBio: shortBio,
                            doList: doList,
                            dontList: dontList,
                            imageURLs: imageURLs,
                            images: images,
                            phoneNumber: phoneNumber)
    }
    
    class func fakeProfileShane()->ProfileData {
        let firstName = "Shane"
        let lastName = "Dara"
        let fullName = "Shane Dara"
        let age = 21
        let interests = ["Basketball", "Healthy living", "Beaches"]
        let shortBio = "This man is the one to take home to your family. He dresses well and actually listens when you tell him about your day - what more could you want??"
        let doList = ["watch him play ball. The man can DUNK."]
        let dontList = ["take him dancing, unless you want him to step on your feet the whole time!"]
        let images: [UIImage] = [UIImage(named: "sample-profile-shane-1")!, UIImage(named: "sample-profile-shane-2")!, UIImage(named: "sample-profile-shane-3")!, UIImage(named: "sample-profile-shane-4")!]
        let endorsedName = "Avery Lamp"
        let imageURLs: [URL] = []
        let phoneNumber = "1234567890"
        return ProfileData( firstName: firstName,
                            lastName: lastName,
                            fullName: fullName,
                            endorsedFullName: endorsedName,
                            age: age,
                            interests: interests,
                            shortBio: shortBio,
                            doList: doList,
                            dontList: dontList,
                            imageURLs: imageURLs,
                            images: images,
                            phoneNumber: phoneNumber)
    }
    
    class func fakeProfileBrooke()->ProfileData {
        let firstName =  "Brooke"
        let lastName =  "Wilder"
        let fullName =  "Brooke Wilder"
        let age =  23
        let interests =  ["Botany", "Yoga", "Travel"]
        let shortBio =  "A literal ray of sunshine who has come to light up your life. Shoot your shot before it’s too late!"
        let doList =  ["ask her to teach you yoga. She is a PROFESSIONAL :O"]
        let dontList =  ["make her spend time indoors. :( She can never sit still."]
        let images: [UIImage] =  [UIImage(named: "sample-profile-brooke-1")!, UIImage(named: "sample-profile-brooke-2")!, UIImage(named: "sample-profile-brooke-3")!]
        let endorsedName = "Avery Lamp"
        let imageURLs: [URL] = []
        let phoneNumber = "1234567890"
        return ProfileData( firstName: firstName,
                            lastName: lastName,
                            fullName: fullName,
                            endorsedFullName: endorsedName,
                            age: age,
                            interests: interests,
                            shortBio: shortBio,
                            doList: doList,
                            dontList: dontList,
                            imageURLs: imageURLs,
                            images: images,
                            phoneNumber: phoneNumber)
    }
}
