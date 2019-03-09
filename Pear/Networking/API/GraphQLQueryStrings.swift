//
//  GraphQLQueryStrings.swift
//  Pear
//
//  Created by Avery Lamp on 3/8/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

class GraphQLQueryStrings {

  static let matchingDemographicsFull: String = "{ethnicities religion political smoking drinking height}"
  // swiftlint:disable:next line_length
  static let matchingPreferencesFull: String = "{ethnicities seekingGender seekingReason reasonDealbreaker seekingEthnicity ethnicityDealbreaker maxDistance distanceDealbreaker minAgeRange maxAgeRange ageDealbreaker minHeightRange maxHeightRange heightDealbreaker }"
  static let imageSizesFull: String = "{original \(GraphQLQueryStrings.imageMetadataFull) large \(GraphQLQueryStrings.imageMetadataFull) medium \(GraphQLQueryStrings.imageMetadataFull) small \(GraphQLQueryStrings.imageMetadataFull) thumbnail \(GraphQLQueryStrings.imageMetadataFull)}"

  static let imageMetadataFull: String = "{imageURL imageID imageSize {width height}}"
}