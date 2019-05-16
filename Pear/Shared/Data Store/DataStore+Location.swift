//
//  DataStore+Location.swift
//  Pear
//
//  Created by Avery Lamp on 4/29/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import CoreLocation

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
      self.lastLocation = location.coordinate
      if let locationDelegate = self.locationDelegate {
        if !self.firstLocationReceived {
          locationDelegate.firstLocationReceived(location: location.coordinate)
          self.firstLocationReceived = true
        }
      }
      
      DataStore.shared.updateLatestLocationAndToken()
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
}
