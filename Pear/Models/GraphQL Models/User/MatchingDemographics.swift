//
//  MatchingDemographics.swift
//  Pear
//
//  Created by Avery Lamp on 5/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum MatchingDemographicsKeys: String, CodingKey {
  case gender
  case age
  case location
  case ethnicity
  case educationLevel
  case religion
  case politicalView
  case drinking
  case smoking
  case cannabis
  case drugs
}

class MatchingDemographics: Decodable, Equatable, GraphQLDecodable {
  static func graphQLAllFields() -> String {
   return "{ gender age location \(LocationObject.graphQLAllFields()) ethnicity \(DemographicsItem<EthnicityEnum>.graphQLAllFields()) educationLevel \(DemographicsItem<EducationLevelEnum>.graphQLAllFields()) religion \(DemographicsItem<ReligionEnum>.graphQLAllFields()) politicalView \(DemographicsItem<PoliticsEnum>.graphQLAllFields()) drinking \(DemographicsItem<HabitsEnum>.graphQLAllFields()) smoking \(DemographicsItem<HabitsEnum>.graphQLAllFields()) cannabis \(DemographicsItem<HabitsEnum>.graphQLAllFields()) drugs \(DemographicsItem<HabitsEnum>.graphQLAllFields()) }"
  }
  
  static func == (lhs: MatchingDemographics, rhs: MatchingDemographics) -> Bool {
    return lhs.gender == rhs.gender &&
      lhs.age == rhs.age &&
      lhs.location == rhs.location
  }
  
  var gender: GenderEnum?
  var age: Int?
  var location: LocationObject?
  var ethnicity: DemographicsItem<EthnicityEnum>
  var educationLevel: DemographicsItem<EducationLevelEnum>
  var religion: DemographicsItem<ReligionEnum>
  var politicalView: DemographicsItem<PoliticsEnum>
  var drinking: DemographicsItem<HabitsEnum>
  var smoking: DemographicsItem<HabitsEnum>
  var cannabis: DemographicsItem<HabitsEnum>
  var drugs: DemographicsItem<HabitsEnum>
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: MatchingDemographicsKeys.self)
    if let genderString = try? values.decode(String.self, forKey: .gender),
      let gender = GenderEnum.init(rawValue: genderString) {
      self.gender = gender
    }
    if let age = try? values.decode(Int.self, forKey: .age) {
      self.age = age
    }
    if let location = try? values.decode(LocationObject.self, forKey: .location) {
      self.location = location
    }
    self.ethnicity = try values.decode(DemographicsItem<EthnicityEnum>.self, forKey: .ethnicity)
    self.educationLevel = try values.decode(DemographicsItem<EducationLevelEnum>.self, forKey: .educationLevel)
    self.religion = try values.decode(DemographicsItem<ReligionEnum>.self, forKey: .religion)
    self.politicalView = try values.decode(DemographicsItem<PoliticsEnum>.self, forKey: .politicalView)
    self.drinking = try values.decode(DemographicsItem<HabitsEnum>.self, forKey: .drinking)
    self.smoking = try values.decode(DemographicsItem<HabitsEnum>.self, forKey: .smoking)
    self.cannabis = try values.decode(DemographicsItem<HabitsEnum>.self, forKey: .cannabis)
    self.drugs = try values.decode(DemographicsItem<HabitsEnum>.self, forKey: .drugs)
  }
}
