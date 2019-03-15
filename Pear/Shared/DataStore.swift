//
//  DataStore.swift
//  Pear
//
//  Created by Avery Lamp on 3/5/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import Firebase

class DataStore {
  
  static let shared = DataStore()
  
  var currentPearUser: PearUser?
  var remoteConfig: RemoteConfig
  
  private init() {
    self.remoteConfig = RemoteConfig.remoteConfig()
    self.remoteConfig.configSettings = RemoteConfigSettings(developerModeEnabled: true)
    self.remoteConfig.setDefaults(fromPlist: "RemoteConfig")
    self.remoteConfig.fetch { (status, error) in
      if let error = error {
        debugPrint("Error fetching remote config: \(error)")
        print("Error fetching remote config: \(error)")
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
      }
    }
  }
  
}
