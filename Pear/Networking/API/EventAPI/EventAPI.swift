//
//  EventAPI.swift
//  Pear
//
//  Created by Brian Gu on 5/27/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
enum EventAPIError: Error {
  case failedDeserialization
  case graphQLError(message: String)
  case unknown
  case unknownError(error: Error)
}

protocol EventAPI {
  func getEvent(eventID: String,
                completion: @escaping(Result<PearEvent, EventAPIError>) -> Void)
}
