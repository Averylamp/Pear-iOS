//
//  SentryHelper.swift
//  Pear
//
//  Created by Avery Lamp on 4/5/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import Sentry

class SentryHelper {
  
  class func generateSentryEvent(level: SentrySeverity = .warning,
                                 apiName: String = "",
                                 functionName: String = "",
                                 message: String,
                                 tags: [String: String] = [:],
                                 paylod: [String: Any] = [:]) {
    print("\n***** GENERATING SENTRY REPORT *****")
    print("***** \(apiName):\(functionName) - \(message) *****\n")
    let skipErrors: [String] = [
    "The network connection was lost.".lowercased(),
    "The request timed out.".lowercased(),
    "The Internet connection appears to be offline.".lowercased(),
    "A data connection is not currently allowed.".lowercased()
    ]
    skipErrors.forEach({
      if  "\(message) - \(apiName):\(functionName)".lowercased().contains($0) {
        print("Found skippable error message")
        return
      }
    })
    
    #if PROD
    let userErrorEvent = Event(level: level)
    userErrorEvent.message = "\(message) - \(apiName):\(functionName)"
    var allTags: [String: String] = ["API": apiName,
                                     "functionName": functionName]
    tags.forEach({ allTags[$0.key] = $0.value })
    userErrorEvent.tags = allTags
    userErrorEvent.extra = paylod
    Client.shared?.send(event: userErrorEvent, completion: nil)
    #endif
  }
  
}
