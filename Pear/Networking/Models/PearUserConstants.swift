//
//  UserConstants.swift
//  SubtleAsianMatches
//
//  Created by Avery on 1/6/19.
//  Copyright © 2019 sam. All rights reserved.
//

import Foundation

struct PearUserKeys {
    static let deactivated = "deactivated"
    static let firebaseToken = "firebaseToken"
    static let firebaseAuthID = "firebaseAuthID"
    static let facebookId = "facebookId"
    static let facebookAccessToken = "facebookAccessToken"
    static let email = "email"
    static let emailVerified = "emailVerified"
    static let phoneNumber = "phoneNumber"
    static let phoneNumberVerified = "phoneNumberVerified"
    static let firstName = "firstName"
    static let lastName = "lastName"
    static let fullName = "fullName"
    static let thumbnailURL = "thumbnailURL"
    static let gender = "gender"
    static let locationName = "locationName"
    static let locationCoordinates = "locationCoordinates"
    static let school = "school"
    static let schoolEmail = "schoolEmail"
    static let schoolEmailVerified = "schoolEmailVerified"
    static let birthdate = "birthdate"
    static let age = "age"
    static let profile_ids = "profile_ids"
    static let profile_objs = "profile_objs"
    static let endorsedProfile_ids = "endorsedProfile_ids"
    static let endorsedProfile_objs = "endorsedProfile_objs"
    
    static let userPreferences = "userPreferences"
    
    static let userStats = "userStats"
    
    static let userDemographics = "userDemographics"
    
    static let userMatches_id = "userMatches_id"
    static let userMatches = "userMatches"
    static let discovery_id = "discovery_id"
    static let discovery_obj = "discovery_obj"
    static let pearPoints = "pearPoints"
}

struct PearUserStatsKeys{
    static let totalNumberOfMatchRequests = "totalNumberOfMatchRequests"
    static let totalNumberOfMatches = "totalNumberOfMatches"
    static let totalNumberOfProfilesCreated = "totalNumberOfProfilesCreated"
    static let totalNumberOfEndorsementsCreated = "totalNumberOfEndorsementsCreated"
    static let conversationTotalNumber = "conversationTotalNumber"
    static let conversationTotalNumberFirstMessage = "conversationTotalNumberFirstMessage"
    static let conversationTotalNumberTenMessages = "conversationTotalNumberTenMessages"
    static let conversationTotalNumberHundredMessages = "conversationTotalNumberHundredMessages"
}

struct PearUserDemographicsKeys{
    static let ethnicities = "ethnicities"
    static let religion = "religion"
    static let political = "political"
    static let smoking = "smoking"
    static let drinking = "drinking"
    static let height = "height"
}

struct PearPreferencesKeys{
    static let ethnicities = "ethnicities"
    static let seekingGender = "seekingGender"
    static let seekingReason = "seekingReason"
    static let reasonDealbreaker = "reasonDealbreaker"
    static let seekingEthnicity = "seekingEthnicity"
    static let ethnicityDealbreaker = "ethnicityDealbreaker"
    static let maxDistance = "maxDistance"
    static let distanceDealbreaker = "distanceDealbreaker"
    static let minAgeRange = "minAgeRange"
    static let maxAgeRange = "maxAgeRange"
    static let ageDealbreaker = "ageDealbreaker"
    static let minHeightRange = "minHeightRange"
    static let maxHeightRange = "maxHeightRange"
    static let heightDealbreaker = "heightDealbreaker"
}
