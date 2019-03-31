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

class DataStore {
  
  static let shared = DataStore()
  
  var currentPearUser: PearUser?
  var remoteConfig: RemoteConfig
  
  private init() {
    self.remoteConfig = RemoteConfig.remoteConfig()
    self.reloadRemoteConfig()
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
