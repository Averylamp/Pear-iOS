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
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    self.locationManager.distanceFilter = 2000.0  // In meters.
    self.locationManager.startUpdatingLocation()
    
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("UPDATED LOCATION")
    if let location = locations.last {
      self.lastLocation = location.coordinate
      if let locationDelegate = self.delegate {
        if !self.firstLocationReceived {
          locationDelegate.firstLocationReceived(location: location.coordinate)
          self.firstLocationReceived = true
        }
      }
      // [Brian] hmm usually by this point, on the first location update we haven't actually retrieved the pear user, so this will no-op
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
    if let locationDelegate = self.delegate {
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
