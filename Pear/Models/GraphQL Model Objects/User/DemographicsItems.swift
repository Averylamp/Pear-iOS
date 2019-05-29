//
//  DemographicsItems.swift
//  Pear
//
//  Created by Avery Lamp on 5/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum DemographicsItemKey: String, CodingKey {
  case response
  case visible
  case userHasResponded
}

class DemographicsItem<E: RawRepresentable>: Decodable, Equatable, GraphQLDecodable, GraphQLInput where E.RawValue == String {
  
  var responses: [E]
  var visible: Bool
  var userHasResponded: Bool
  
  func toGraphQLInput() -> [String: Any] {
    let values: [String: Any] = [
      DemographicsItemKey.response.rawValue: self.responses.map({ $0.rawValue }),
      DemographicsItemKey.visible.rawValue: self.visible,
      DemographicsItemKey.userHasResponded.rawValue: self.userHasResponded
    ]
    return values
  }
  
  static func graphQLAllFields() -> String {
    return "{ response visible userHasResponded }"
  }
  
  static func == (lhs: DemographicsItem, rhs: DemographicsItem) -> Bool {
    return false
  }
  
  func toOptionalString(mapFunction: (E) -> String) -> String? {
    if self.responses.count == 0 {
      return nil
    }
    return self.responses.map(mapFunction).joined(separator: ", ")
  }
  
  func toInfoItem(type: UserInfoType, mapFunction: (E) -> String) -> InfoTableViewItem {
    let response = self.toOptionalString(mapFunction: mapFunction)
    return InfoTableViewItem(type: type,
                      subtitleText: response != nil ? response! : (type.requiredItem() ? "Required": "Optional"),
                      visibility: self.visible, filledOut: response != nil, requiredFilledOut: type.requiredItem())
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: DemographicsItemKey.self)
    self.visible = try values.decode(Bool.self, forKey: .visible)
    self.userHasResponded = try values.decode(Bool.self, forKey: .userHasResponded)
    let stringResponses = try values.decode([String].self, forKey: .response)
    self.responses = stringResponses.compactMap({ E.init(rawValue: $0) })
  }
  
}

enum EthnicityEnum: String {
  case americanIndian = "AMERICAN_INDIAN"
  case blackAfrican = "BLACK_AFRICAN_DESCENT"
  case eastAsian = "EAST_ASIAN"
  case hispanicLatino = "HISPANIC_LATINO"
  case middleEastern = "MIDDLE_EASTERN"
  case pacificIslander = "PACIFIC_ISLANDER"
  case southAsian = "SOUTH_ASIAN"
  case whiteCaucasian = "WHITE_CAUCASIAN"
  case other = "OTHER"
  
  func toString() -> String {
    switch self {
    case .americanIndian:
      return "American Indian"
    case .blackAfrican:
      return "Black/African"
    case .eastAsian:
      return "East Asian"
    case .hispanicLatino:
      return "Hispanic/Latino"
    case .middleEastern:
      return "Middle Eastern"
    case .pacificIslander:
      return "Pacific Islander"
    case .southAsian:
      return "South Asian"
    case .whiteCaucasian:
      return "White/Caucasian"
    case .other:
      return "Other"
    }
  }
  
  func itemKey() -> String {
    return "ethnicity"
  }
  
}

enum EducationLevelEnum: String {
  case highSchool = "HIGH_SCHOOL"
  case underGrad = "UNDERGRAD"
  case postGrad = "POSTGRAD"
  case preferNotToSay = "PREFER_NOT_TO_SAY"
  
  func toString() -> String {
    switch self {
    case .highSchool:
      return "High School"
    case .underGrad:
      return "Undergrad"
    case .postGrad:
      return "Post Grad"
    case .preferNotToSay:
      return "Prefer not to say"
    }
  }
  
  func itemKey() -> String {
    return "educationLevel"
  }
  
}

enum ReligionEnum: String {
  case buddhist = "BUDDHIST"
  case catholic = "CATHOLIC"
  case christian = "CHRISTIAN"
  case hindu = "HINDU"
  case jewish = "JEWISH"
  case muslim = "MUSLIM"
  case spiritual = "SPIRITUAL"
  case agnostic = "AGNOSTIC"
  case atheist = "ATHEIST"
  case other = "OTHER"
  
  func toString() -> String {
    switch self {
    case .buddhist:
      return "Buddhist"
    case .catholic:
      return "Catholic"
    case .christian:
      return "Christian"
    case .hindu:
      return "Hindu"
    case .jewish:
      return "Jewish"
    case .muslim:
      return "Muslim"
    case .spiritual:
      return "Spiritual"
    case .agnostic:
      return "Agnostic"
    case .atheist:
      return "Atheist"
    case .other:
      return "Other"
    }
  }
  
  func itemKey() -> String {
    return "religion"
  }
  
}

enum PoliticsEnum: String {
  case liberal = "LIBERAL"
  case moderate = "MODERATE"
  case conservative = "CONSERVATIVE"
  case other = "OTHER"
  case preferNotToSay = "PREFER_NOT_TO_SAY"
  
  func toString() -> String {
    switch self {
    case .liberal:
      return "Liberal"
    case .moderate:
      return "Moderate"
    case .conservative:
      return "Conservative"
    case .other:
      return "Other"
    case .preferNotToSay:
      return "Prefer not to say"
    }
  }
  
  func itemKey() -> String {
    return "politicalView"
  }
  
}

enum HabitsEnum: String {
  case yes = "YES"
  case sometimes = "SOMETIMES"
  // swiftlint:disable:next identifier_name
  case no = "NO"
  case preferNotToSay = "PREFER_NOT_TO_SAY"

  func toString() -> String {
    switch self {
    case .yes:
      return "Yes"
    case .sometimes:
      return "Sometimes"
    case .no:
      return "No"
    case .preferNotToSay:
      return "Prefer not to say"
    }
  }
}
