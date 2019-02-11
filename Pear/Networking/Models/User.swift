//
//  User.swift
//  SubtleAsianMatches
//
//  Created by Kelvin Lau on 2018-12-26.
//  Copyright © 2018 sam. All rights reserved.
//

import Foundation
import Firebase

class PearUser {
    
    let documentId: String
    let email: String
    let firstName: String
    let lastName: String
    let fbId: String
    let firebaseId: String
    
    var personalProfileRef: Profile?
    var friendEndorsedProfileRefs: Array<Profile> = []
    var endorsedProfileRefs: Array<Profile> = []
    
    init(){
        self.documentId = ""
        self.email = ""
        self.firstName = ""
        self.lastName = ""
        self.fbId = ""
        self.firebaseId = ""
    }
    
    init(documentId: String,
         email: String,
         firstName: String,
         lastName: String,
         fbId: String,
         firebaseId: String,
         personalProfileRef: Profile? = nil,
         endorsedProfileRefs: Array<Profile> = [],
         friendEndorsedProfileRefs: Array<Profile> = []){
        self.documentId = documentId
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.fbId = fbId
        self.firebaseId = firebaseId
        
        self.personalProfileRef = personalProfileRef
        self.endorsedProfileRefs = endorsedProfileRefs
        self.friendEndorsedProfileRefs = friendEndorsedProfileRefs
    }
    
    convenience init?(dictionary: [String: Any?]) {
        guard
            let documentId = dictionary[UserKeys.documentId] as? String,
            let email = dictionary[UserKeys.email] as? String,
            let firstName = dictionary[UserKeys.firstName] as? String,
            let lastName = dictionary[UserKeys.lastName] as? String,
            let fbId = dictionary[UserKeys.fbId] as? String,
            let firebaseId = dictionary[UserKeys.firebaseId] as? String
        else{
            return nil
        }
        let personalProfileRef = dictionary[UserKeys.personalProfileRefs] as? Profile
        let endorsedProfileRefs = dictionary[UserKeys.endorsedProfileRefs] as? Array<Profile>
        let friendEndorsedProfileRefs = dictionary[UserKeys.friendEndorsedProfileRefs] as? Array<Profile>
        
        self.init(documentId: documentId,
                  email: email,
                  firstName: firstName,
                  lastName: lastName,
                  fbId: fbId,
                  firebaseId: firebaseId,
                  personalProfileRef: personalProfileRef ?? nil,
                  endorsedProfileRefs: endorsedProfileRefs ?? [],
                  friendEndorsedProfileRefs: friendEndorsedProfileRefs ?? [])
    }
    
    class func initFakeUser()->PearUser{
        let fakeData: [String: Any?] = [
            UserKeys.documentId: "FakeId",
            UserKeys.email: "averylamp@gmail.com",
            UserKeys.firstName: "Avery",
            UserKeys.lastName: "Lamp",
            UserKeys.fbId: "FakeId",
            UserKeys.firebaseId: "FakeId",
            UserKeys.personalProfileRefs: [Profile.initFakeProfile()],
            UserKeys.endorsedProfileRefs: [Profile.initFakeProfile(),Profile.initFakeProfile(),Profile.initFakeProfile()],
            UserKeys.friendEndorsedProfileRefs: [Profile.initFakeProfile()]
        ]
        return PearUser(dictionary: fakeData)!
    }
    
    
}
