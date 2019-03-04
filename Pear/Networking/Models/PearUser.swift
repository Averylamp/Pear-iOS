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
    var emailVerified: Bool
    var phoneNumber: String
    var phoneNumberVerified: Bool
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
    static let graphQLUserFields: String = "user { _id deactivated firebaseToken firebaseAuthID facebookId facebookAccessToken email emailVerified phoneNumber phoneNumberVerified firstName lastName fullName thumbnailURL gender locationName locationCoordinates school schoolEmail schoolEmailVerified birthdate age profile_ids endorsedProfile_ids userPreferences {   seekingGender } userStats {   totalNumberOfMatches   totalNumberOfMatches } userDemographics {   ethnicities } userMatches_id discovery_id pearPoints    }"
    
    init() {
        fatalError("Should never be called to generate")
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: PearUserKeys.self)
        print(values)
        self.documentID = try values.decode(String.self, forKey: .documentID)
        self.deactivated = try values.decode(Bool.self, forKey: .deactivated)
        self.firebaseToken = try values.decode(String.self, forKey: .firebaseToken)
        self.firebaseAuthID = try values.decode(String.self, forKey: .firebaseAuthID)
        self.facebookId = try? values.decode(String.self, forKey: .facebookId)
        self.facebookAccessToken = try? values.decode(String.self, forKey: .facebookAccessToken)
        self.email = try values.decode(String.self, forKey: .email)
        self.emailVerified = try values.decode(Bool.self, forKey: .emailVerified)
        self.phoneNumber = try values.decode(String.self, forKey: .phoneNumber)
        self.phoneNumberVerified = try values.decode(Bool.self, forKey: .phoneNumberVerified)
        self.firstName = try values.decode(String.self, forKey: .firstName)
        self.lastName = try values.decode(String.self, forKey: .lastName)
        self.fullName = try values.decode(String.self, forKey: .fullName)
        self.thumbnailURL = try? values.decode(String.self, forKey: .thumbnailURL)
        self.gender = try? values.decode(String.self, forKey: .gender)
        self.locationName = try? values.decode(String.self, forKey: .locationName)
        self.locationCoordinates = try? values.decode(String.self, forKey: .locationCoordinates)
        self.school = try? values.decode(String.self, forKey: .school)
        self.schoolEmail = try? values.decode(String.self, forKey: .schoolEmail)
        self.schoolEmailVerified = try? values.decode(String.self, forKey: .schoolEmailVerified)
        self.birthdate = try? values.decode(Date.self, forKey: .birthdate)
        self.age = try values.decode(Int.self, forKey: .age)
    }
    
}

extension PearUser {
    
}
