//
//  PearDetachedProfile.swift
//  Pear
//
//  Created by Avery Lamp on 3/8/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

class PearDetachedProfile: GettingStartedUserProfileData {
  
  static let graphQLDetachedProfileFields = "{ _id creatorUser_id firstName phoneNumber age gender interests vibes bio dos donts imageIDs images \(GraphQLQueryStrings.imageSizesFull) matchingDemographics \(GraphQLQueryStrings.matchingDemographicsFull) matchingPreferences \(GraphQLQueryStrings.matchingPreferencesFull) }"
  
}
