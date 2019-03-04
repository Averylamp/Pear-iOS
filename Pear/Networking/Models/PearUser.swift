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

class PearUser: Codable {
    var documentID: String
    var deactivated: Bool
    var firebaseToken: String
    var firebaseAuthID: String
    var facebookId: String?
    var facebookAccessToken: String?
    var email: String
    var emailVerified: String
    var phoneNumber: String
    var phoneNumberVerified: String
    var firstName: String
    var lastName: String
    var fullName: String
    var thumbnailURL: String?
    var gender: String?
    var locationName: String?
    var locationCoordinates: String?
    var school: String?
    var schoolEmail: String?
    var schoolEmailVerified: String?
    var birthdate: Date?
    var age: Int
//    var profileIDs: []
//    var profileObjs: [String?]
//    var endorsedProfileIDs: []
//    var endorsedProfileObjs: [String?]
//    var userPreferences: String?
//    var userStats: String?
//    var userDemographics: String?
//    var userMatchesID: String?
//    var userMatches: String?
//    var discoveryIDs: String?
//    var discoveryObj: String?
//    var pearPoints: String?

    // swiftlint:disable:next line_length
    static let graphQLUserFields: String = "user { _id deactivated firebaseToken firebaseAuthID facebookId facebookAccessToken email phoneNumber phoneNumberVerified firstName lastName thumbnailURL gender locationName locationCoordinates school schoolEmail schoolEmailVerified birthdate age profile_ids endorsedProfile_ids userPreferences {   seekingGender } userStats {   totalNumberOfMatches   totalNumberOfMatches } userDemographics {   ethnicities } userMatches_id discovery_id pearPoints    }"

    init() {
        fatalError("Should never be called to generate")
    }
}

extension PearUser {

}
