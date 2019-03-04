//
//  PearUser.swift
//  Pear
//
//  Created by Avery Lamp on 2019-3-4.
//  Copyright © 2019 Pear. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

class PearUser {

    // swiftlint:disable:next line_length
    static let graphQLUserFields: String = "user { _id deactivated firebaseToken firebaseAuthID facebookId facebookAccessToken email phoneNumber phoneNumberVerified firstName lastName thumbnailURL gender locationName locationCoordinates school schoolEmail schoolEmailVerified birthdate age profile_ids endorsedProfile_ids userPreferences {   seekingGender } userStats {   totalNumberOfMatches   totalNumberOfMatches } userDemographics {   ethnicities } userMatches_id discovery_id pearPoints    }"

    let documentId: String
    let email: String
    let firstName: String
    let lastName: String
    let fbId: String
    let firebaseId: String

    var personalProfileRef: OldProfile?
    var friendEndorsedProfileRefs: [OldProfile] = []
    var endorsedProfileRefs: [OldProfile] = []

    init() {
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
         personalProfileRef: OldProfile? = nil,
         endorsedProfileRefs: [OldProfile] = [],
         friendEndorsedProfileRefs: [OldProfile] = []) {
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
            let documentId = dictionary[PearUserKeys.documentId] as? String,
            let email = dictionary[PearUserKeys.email] as? String,
            let firstName = dictionary[PearUserKeys.firstName] as? String,
            let lastName = dictionary[PearUserKeys.lastName] as? String,
            let fbId = dictionary[PearUserKeys.fbId] as? String,
            let firebaseId = dictionary[PearUserKeys.firebaseId] as? String
            else {
                return nil
        }
        let personalProfileRef = dictionary[PearUserKeys.personalProfileRefs] as? OldProfile
        let endorsedProfileRefs = dictionary[PearUserKeys.endorsedProfileRefs] as? [OldProfile]
        let friendEndorsedProfileRefs = dictionary[PearUserKeys.friendEndorsedProfileRefs] as? [OldProfile]

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
    
    convenience init?(json: JSON){
        
    }

    class func initFakeUser() -> PearUser {
        let fakeData: [String: Any?] = [
            PearUserKeys.documentId: "FakeId",
            PearUserKeys.email: "averylamp@gmail.com",
            PearUserKeys.firstName: "Avery",
            PearUserKeys.lastName: "Lamp",
            PearUserKeys.fbId: "FakeId",
            PearUserKeys.firebaseId: "FakeId",
            PearUserKeys.personalProfileRefs: [OldProfile.initFakeProfile()],
            PearUserKeys.endorsedProfileRefs: [OldProfile.initFakeProfile(), OldProfile.initFakeProfile(), OldProfile.initFakeProfile()],
            PearUserKeys.friendEndorsedProfileRefs: [OldProfile.initFakeProfile()]
        ]
        return PearUser(dictionary: fakeData)!
    }

}
