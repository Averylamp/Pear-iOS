//
//  PearContentAPI.swift
//  Pear
//
//  Created by Avery Lamp on 4/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class PearContentAPI: ContentAPI {
  
  static let shared = PearContentAPI()
  
  private init() {
    
  }
  
  let defaultHeaders: [String: String] = [
    "Content-Type": "application/json"
  ]

  static let getQuestionsQuery: String = "query{ getAllQuestions  \(QuestionItem.graphQLAllFields())  }"
  
}

// MARK: - Routes
extension PearContentAPI {
  func getQuestions(completion: @escaping(Result<[QuestionItem], ContentAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    let fullDictionary: [String: Any] = ["query": PearContentAPI.getQuestionsQuery]
    do {
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      request.httpBody = data
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(ContentAPIError.unknownError(error: error)))
          return
        } else {
          if let data = data,
            let json = try? JSON(data: data),
            let questionArray = json["data"]["getAllQuestions"].array {
            var allQuestions: [QuestionItem] = []
            for questionJSON in questionArray {
              do {
                let questionData = try questionJSON.rawData()
                let questionItem = try JSONDecoder().decode(QuestionItem.self, from: questionData)
                allQuestions.append(questionItem)
              } catch {
                print("Error decoding Question Item: \(error)")
              }
              
            }
            completion(.success(allQuestions))
          } else {
            completion(.failure(ContentAPIError.failedDeserialization))
          }
        }
      }
      dataTask.resume()

    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearContentAPI",
                                       functionName: "getAllQuestions",
                                       message: error.localizedDescription)
      completion(.failure(ContentAPIError.unknownError(error: error)))

    }

  }
}
