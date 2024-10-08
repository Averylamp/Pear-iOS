//
//  UpdateUserAPI.swift
//  Pear
//
//  Created by Avery Lamp on 5/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
enum UpdateUserAPIError: Error {
  case unknownError(error: Error)
  case invalidVariables
  case failedDeserialization
  case unauthenticated
  case currentUserNotFound
  case graphQLError(message: String)
}

protocol UpdateUserAPI {
  
  func updateUserName(firstName: String?,
                      lastName: String?,
                      completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void)
  
  func updateUserAge(birthdate: Date,
                     completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void)
  
  func updateUserGender(gender: GenderEnum,
                        completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void)
  
  func updateUserSchool(schoolName: String?,
                        schoolYear: String?,
                        completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void)
  
  func updateUserDemographicsItems<E: RawRepresentable>(items: [E],
                                                        keyName: String,
                                                        completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void) where E.RawValue == String
  
  func updateUserDemographicsItem<E: RawRepresentable>(item: E,
                                                       keyName: String,
                                                       completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void) where E.RawValue == String
  
  func updateUserMatchingPreferences(seekingGenders: [GenderEnum],
                                     minAge: Int,
                                     maxAge: Int,
                                     completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void)
  
  func updateUserIsSeeking(seeking: Bool,
                           completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void)
  
  func updateUserPrompts(prompts: [QuestionResponseItem],
                         completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void)
  
}
