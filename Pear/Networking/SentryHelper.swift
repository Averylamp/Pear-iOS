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
                                 responseData: Data? = nil,
                                 tags: [String: String] = [:],
                                 payload: [String: Any] = [:]) {
    print("\n***** GENERATING SENTRY REPORT *****")
    print("***** \(apiName):\(functionName) - \(message) *****\n")
    let skipErrors: [String] = [
    "The network connection was lost.".lowercased(),
    "The request timed out.".lowercased(),
    "The Internet connection appears to be offline.".lowercased(),
    "A data connection is not currently allowed.".lowercased(),
    "The operation couldn’t be completed. Software caused connection abort".lowercased()
    ]
    var skipError = false
    skipErrors.forEach({
      if  "\(message) - \(apiName):\(functionName)".lowercased().contains($0) {
        print("Found skippable error message")
        skipError = true
      }
    })
    if skipError {
      return
    }
    #if DEVMODE
    print(payload)
    APIHelpers.printDataDump(data: responseData)
    fatalError("Some Network Call failed and sentry is generating an error")
    #endif
    
    #if PROD
    let userErrorEvent = Event(level: level)
    userErrorEvent.message = "\(message) - \(apiName):\(functionName)"
    var allTags: [String: String] = ["API": apiName,
                                     "functionName": functionName]
    tags.forEach({ allTags[$0.key] = $0.value })
    userErrorEvent.tags = allTags
    var extraTags: [String: Any] = [:]
    paylod.forEach({ extraTags[$0.key] = $0.value })
    if let responseString = APIHelpers.dataDumpToString(data: responseData) {
      extraTags["response"] = responseString
    }
    userErrorEvent.extra = extraTags
    Client.shared?.send(event: userErrorEvent, completion: nil)
    #endif
  }
  
  class func generateSentryMessageEvent(level: SentrySeverity,
                                        message: String,
                                        tags: [String: String] = [:],
                                        extra: [String: Any] = [:]) {
    
    print("\n***** GENERATING SENTRY REPORT *****")
    print(message)
    print(tags)
    print(extra)
    #if DEVMODE
    fatalError("A sentry mesage has been generated: \(message)")
    #endif
    
    #if PROD
    let event = Event(level: level)
    event.message = message
    event.tags = tags
    var extraTags: [String: Any] = [:]
    extra.forEach({ extraTags[$0.key] = $0.value })
    event.extra = extra
    Client.shared?.send(event: event, completion: nil)
    #endif
  }
  
}
