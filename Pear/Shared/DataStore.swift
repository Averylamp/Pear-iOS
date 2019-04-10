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
  
  weak var delegate: DataStoreLocationDelegate?
  var currentPearUser: PearUser? {
    didSet {
      NotificationCenter.default.post(name: .refreshMeTab, object: nil)
    }
  }
  var endorsedUsers: [MatchingPearUser] = [] {
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
  var remoteConfig: RemoteConfig
  var locationManager: CLLocationManager
  var firstLocationReceived: Bool = false
  var lastLocation: CLLocationCoordinate2D?
  var firebaseRemoteInstanceID: String? // for push notifications via Firebase Cloud Messaging
  
  // @avery please check this and LMK if it's wrong (i.e. things in wrong order etc)
  private override init() {
    self.remoteConfig = RemoteConfig.remoteConfig()
    self.locationManager = CLLocationManager()
    super.init()
    
    self.reloadRemoteConfig()
    self.locationManager.delegate = self
    self.startReceivingLocationChanges()
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

extension DataStore: CLLocationManagerDelegate {
  
  func startReceivingLocationChanges() {
    let authorizationStatus = CLLocationManager.authorizationStatus()
    if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
      print("location services not authorized")
      // User has not authorized access to location information.
      return
    }
    // Do not start services that aren't available.
    if !CLLocationManager.locationServicesEnabled() {
      print("location services not enabled")
      // Location services is not available.
      return
    }
    // Configure and start the service.
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    self.locationManager.distanceFilter = 2000.0  // In meters.
    self.locationManager.startUpdatingLocation()
    
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      self.lastLocation = location.coordinate
      if let locationDelegate = self.delegate {
        if !self.firstLocationReceived {
          locationDelegate.firstLocationReceived(location: location.coordinate)
          self.firstLocationReceived = true
        }
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    if let error = error as? CLError, error.code == .denied {
      manager.stopUpdatingLocation()
      return
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if let locationDelegate = self.delegate {
      locationDelegate.authorizationStatusChanged(status: status)
    }
  }
  
}
