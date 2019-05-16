//
//  DataStore+Location.swift
//  Pear
//
//  Created by Avery Lamp on 4/29/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

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
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    self.locationManager.distanceFilter = 100.0  // In meters.
    self.locationManager.startUpdatingLocation()
    
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      if let locationDelegate = self.locationDelegate {
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
    if let locationDelegate = self.locationDelegate {
      locationDelegate.authorizationStatusChanged(status: status)
    }
  }
  
  func hasEnabledLocation() -> Bool {
    let status = CLLocationManager.authorizationStatus()
    switch status {
    case .notDetermined, .restricted, .denied:
      return false
    case .authorizedAlways, .authorizedWhenInUse:
      return true
    default:
      return false
    }
  }
  
  func withinBostonArea(completion: (Bool?) -> Void) {
    if let lastLocation = locationManager.location?.coordinate,
      DataStore.shared.remoteConfig.configValue(forKey: "location_blocking_enabled").boolValue {
      let bostonLocation = CLLocationCoordinate2D(latitude: 42.362485733571845, longitude: -71.1014485358899)
      let milesDistance = bostonLocation.distanceMiles(other: lastLocation)
      var foundWithin = false
      if let milesFromBoston = DataStore.shared.remoteConfig.configValue(forKey: "distance_from_boston").numberValue?.doubleValue {
        foundWithin = milesDistance <= milesFromBoston
      } else {
        foundWithin = milesDistance <= 200.0
      }
      foundWithin = false
      if !foundWithin {
        let whitelistedNumbersData = DataStore.shared.remoteConfig.configValue(forKey: "whitelisted_phone_numbers").dataValue
        if let whitelistedNumbersArray = try? JSON(data: whitelistedNumbersData).array,
          let userPhoneNumber = DataStore.shared.currentPearUser?.phoneNumber {
          let whitelistedNumbersStringArray = whitelistedNumbersArray.compactMap({ $0.string })
          print(whitelistedNumbersStringArray)
          if whitelistedNumbersStringArray.contains(userPhoneNumber) {
            foundWithin = true
          }
        } else {
          print("failed to find whitelisted numbers")
        }
      }
      completion(foundWithin)
      return
    }
    completion(nil)
  }
  
}
