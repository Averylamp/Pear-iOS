//
//  SlackHelper.swift
//  Pear
//
//  Created by Avery Lamp on 6/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class SlackHelper: NSObject {
  
  var userEvents: [SlackEvent] = []
  var startTime: Double = CACurrentMediaTime()
  
  struct SlackEvent {
    let text: String
    let color: String
  }
  
  static let shared = SlackHelper()
  
  private override init() {
    super.init()
    self.startNewSession()
  }
  
  func startNewSession() {
    self.userEvents = []
    self.startTime = CACurrentMediaTime()
    
    self.addUserInformation()
  }
  
  func addUserInformation() {
    if let user = DataStore.shared.currentPearUser {
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(20 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {        
        if !self.userEvents.contains(where: {
          $0.text == user.toSlackStorySummary(profileStats: true, currentUserStats: true)
        }) {
          self.userEvents.insert(SlackEvent(text: user.toSlackStorySummary(profileStats: true, currentUserStats: true),
                                            color: UIColor.green.hexColor), at: 0)
        }
      }
    }
  }
  
  func addEvent(text: String, color: UIColor = UIColor.black) {
    self.userEvents.append(SlackEvent(text: text, color: color.hexColor))
    if self.userEvents.count == 98 {
      self.userEvents.append(SlackEvent(text: "Too many events, continuing with a new session", color: UIColor.purple.hexColor))
      self.sendStory()
    }
  }
  
  func getAttachmentsFromEvents() -> [[String: Any]] {
    return userEvents.map({
      [
        "text": $0.text,
        "color": $0.color
      ]
    })
  }
  
  func sendStory() {
    #if DEVMODE
    //    return
    #endif
    let timePassed = CACurrentMediaTime() - self.startTime
    if timePassed < 30 || self.userEvents.count < 4 {
      return
    }
    if !DataStore.shared.remoteConfig.configValue(forKey: "slack_stores_enabled").boolValue {
      return
    }
    if let phoneNumber = DataStore.shared.currentPearUser?.phoneNumber {
      let skippedStoresData = DataStore.shared.remoteConfig.configValue(forKey: "slack_stores_skipped_phone_numbers").dataValue
      if let skippedPhoneNumberArray = try? JSON(data: skippedStoresData).array {
        let skippedPhoneNumbers = skippedPhoneNumberArray.compactMap({ $0.string })
        if skippedPhoneNumbers.contains(phoneNumber) {
          return
        }
      }
    }
    
    let sessionNumber = UserDefaults.standard.integer(forKey: UserDefaultKeys.userSessionNumber.rawValue)
    UserDefaults.standard.set(sessionNumber + 1, forKey: UserDefaultKeys.userSessionNumber.rawValue)
    self.userEvents.insert(SlackEvent(text: "Session Duration: \(Int(timePassed))s, Session Number: \(sessionNumber), Events: \(self.userEvents.count)", color: UIColor.purple.hexColor), at: 0)
    let urlString = "https://hooks.slack.com/services/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"
    let url = URL(string: urlString)
    let rawData: [String: Any] = [
      "attachments": self.getAttachmentsFromEvents()
    ]
    if let url = url,
      let data = try? JSONSerialization.data(withJSONObject: rawData, options: .prettyPrinted) {
      var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
      request.httpMethod = "POST"
      request.addValue("application/json", forHTTPHeaderField: "Content-type")
      request.httpBody = data
      let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
        if let error = error {
          print("Error sending story: \(error)")
        }
        if let data = data {
          print(data)
        }
        self.startNewSession()
      }
      dataTask.resume()
    }
    
  }
  
}
