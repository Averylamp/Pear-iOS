//
//  ContentAPI.swift
//  Pear
//
//  Created by Avery Lamp on 4/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum ContentAPIError: Error {
  case unknownError(error: Error)
  case failedDeserialization
  case graphQLError(message: String)
}

protocol ContentAPI {
  func getQuestions(completion: @escaping(Result<[QuestionItem], ContentAPIError>) -> Void)
}
