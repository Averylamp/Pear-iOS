//
//  DataStore.swift
//  Pear
//
//  Created by Avery Lamp on 3/5/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON
import CoreLocation

protocol DataStoreLocationDelegate: AnyObject {
  
  func firstLocationReceived(location: CLLocationCoordinate2D)
  
  func authorizationStatusChanged(status: CLAuthorizationStatus)
  
}

class DataStore: NSObject {
  
  static let shared = DataStore()
  
  weak var locationDelegate: DataStoreLocationDelegate?
  
  var currentPearUser: PearUser? {
    didSet {
      NotificationCenter.default.post(name: .refreshMeTab, object: nil)
    }
  }
  var endorsedUsers: [PearUser] = [] {
    didSet {
      NotificationCenter.default.post(name: .refreshFriendTab, object: nil)
    }
  }
  var detachedProfiles: [PearDetachedProfile] = [] {
    didSet {
      NotificationCenter.default.post(name: .refreshFriendTab, object: nil)
    }
  }
  var filterForEndorsedUsers: [Bool] = []
  var filterForDetachedProfiles: [Bool] = []
  
  var matchRequests: [Match] = []
  var currentMatches: [Match] = []
  var remoteConfig: RemoteConfig
  var locationManager: CLLocationManager
  var firstLocationReceived: Bool = false
  
  var firebaseRemoteInstanceID: String? // for push notifications via Firebase Cloud Messaging
  var possibleQuestions: [QuestionItem] = []
  
  private override init() {
    self.remoteConfig = RemoteConfig.remoteConfig()
    self.locationManager = CLLocationManager()
    super.init()
    self.reloadRemoteConfig()
    self.locationManager.delegate = self
    self.startReceivingLocationChanges()
    self.reloadPossibleQuestions()
  }
  
  func reloadRemoteConfig(completion: ((Bool) -> Void)? = nil) {
    #if DEVMODE
    self.remoteConfig.configSettings = RemoteConfigSettings(developerModeEnabled: true)
    #endif
    #if PROD
    self.remoteConfig.configSettings = RemoteConfigSettings()
    #endif
    self.remoteConfig.setDefaults(fromPlist: "RemoteConfig")
    self.remoteConfig.fetch { (status, error) in
      if let error = error {
        print("Error fetching remote config: \(error)")
        if let completion = completion {
          completion(false)
        }
        return
      }
      switch status {
      case .success:
        self.remoteConfig.activateFetched()
        print("Remote Config fetched successfully")
      case .failure:
        print("Failure fetching remote config")
      case .noFetchYet:
        print("Remote Config fetching not fetched yet")
      case .throttled:
        print("Remote Config fetching throttled")
      @unknown default:
        fatalError()
      }
      
      if let completion = completion {
        completion(status == .success)
      }
    }
  }
  
}
