//
//  SlackHelper.swift
//  Pear
//
//  Created by Avery Lamp on 6/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

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
        let demographicsText = "User: \(user.firstName ?? "") \((user.lastName ?? "").firstCapitalized). (\(user.age ?? 0)) \(user.gender?.toString() ?? "Unknown Gender")"
        let unreadMessages = DataStore.shared.currentMatches.filter({ if
          let lastMessage = $0.chat?.messages.last,
          let lastOpened = $0.chat?.lastOpenedDate
        {
          let unread = lastOpened.compare(lastMessage.timestamp) == .orderedAscending
          return unread
          }
          return false
        }).count
        let userStats = "Images: \(user.displayedImages.count), Friends: \(user.endorsedUserIDs.count), Matches: \(DataStore.shared.currentMatches.count), Unread Messages: \(unreadMessages), \(DataStore.shared.matchRequests.count > 0 ? "Requests: \(DataStore.shared.matchRequests.count)," : "") \(DataStore.shared.detachedProfiles.count > 0 ? "Detached Profiles: \(DataStore.shared.detachedProfiles.count)" : "") "
        if !self.userEvents.contains(where: {
          $0.text == "\(demographicsText)\n\(userStats)"
        }) {
          self.userEvents.insert(SlackEvent(text: "\(demographicsText)\n\(userStats)", color: UIColor.green.hexColor), at: 0)
        }
      }
    }
  }
  
  func addEvent(text: String, color: UIColor = UIColor.black) {
    self.userEvents.append(SlackEvent(text: text, color: color.hexColor))
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
    let sessionNumber = UserDefaults.standard.integer(forKey: UserDefaultKeys.userSessionNumber.rawValue)
    UserDefaults.standard.set(sessionNumber + 1, forKey: UserDefaultKeys.userSessionNumber.rawValue)
    self.userEvents.insert(SlackEvent(text: "Session Duration: \(Int(timePassed))s, Session Number: \(sessionNumber)\nEvents: \(self.userEvents.count)", color: UIColor.green.hexColor), at: 0)
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
