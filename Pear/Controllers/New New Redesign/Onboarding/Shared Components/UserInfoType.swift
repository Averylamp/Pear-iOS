//
//  UserInfoType.swift
//  Pear
//
//  Created by Avery Lamp on 5/22/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
enum UserInfoType {
  case name
  case age
  case gender
  case height
  case ethnicity
  case school
  case work
  case jobTitle
  case hometown
  case education
  case religion
  case political
  case drinking
  case smoking
  case cannabis
  case drugs
  
  func toTitleString() -> String {
    switch self {
    case .name:
      return "Name"
    case .age:
      return "Age"
    case .gender:
      return "Gender"
    case .height:
      return "Height"
    case .ethnicity:
      return "Ethnicity"
    case .school:
      return "School"
    case .work:
      return "Work"
    case .jobTitle:
      return "Job Title"
    case .hometown:
      return "Hometown"
    case .education:
      return "Education Level"
    case .religion:
      return "Religion & Spirituality"
    case .political:
      return "Political Views"
    case .drinking:
      return "Drinking"
    case .smoking:
      return "Smoking"
    case .cannabis:
      return "Cannabis"
    case .drugs:
      return "Drugs"
    }
  }
  
  func defaultVisibility() -> Bool {
    switch self {
    case .name, .age, .gender, .school, .work, .jobTitle, .hometown:
      return true
    case .height, .ethnicity, .education, .religion, .political, .drinking, .smoking, .cannabis, .drugs:
      return false
    }
  }
  
  func requiredItem() -> Bool {
    switch self {
    case .name, .age, .gender:
      return true
    case .height, .ethnicity, .school, .work, .jobTitle, .hometown, .education,
         .religion, .political, .drinking, .smoking, .cannabis, .drugs:
      return false
    }
  }
  
}
