//
//  GetStartedLocationViewController.swift
//  Pear
//
//  Created by Brian Gu on 3/29/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import CoreLocation

class GetStartedLocationViewController: UIViewController {
  
  var gettingStartedUserData: OldUserCreationData!
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  @IBOutlet weak var enableLocationButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedUserData: OldUserCreationData) -> GetStartedLocationViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedLocationViewController.self), bundle: nil)
    guard let allowLocationVC = storyboard.instantiateInitialViewController() as? GetStartedLocationViewController else { return nil }
    allowLocationVC.gettingStartedUserData = gettingStartedUserData
    return allowLocationVC
  }
  
  @IBAction func enableLocationClicked(_ sender: Any) {
    print("enable location clicked")
    let status = CLLocationManager.authorizationStatus()
    print("authorization status is \(status)")
    self.handleAuthorizationStatus(status: status)
  }
  
  func validateLocation(location: CLLocationCoordinate2D) {
    
    print("validateLocation")
    if let location = DataStore.shared.lastLocation {
      self.gettingStartedUserData.lastLocation = location
    }
    guard let nextVC = self.gettingStartedUserData.getNextInputViewController() else {
      print("Failed to create next vc")
      return
    }
    self.navigationController?.setViewControllers([nextVC], animated: true)
    
  }
  
  func handleAuthorizationStatus(status: CLAuthorizationStatus) {
    if status == .notDetermined {
      // present an alert indicating location authorization required
      // and offer to take the user to Settings for the app via
      // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
      
      DataStore.shared.locationManager.requestWhenInUseAuthorization()
    } else if status == .denied {
      DispatchQueue.main.async {
        let alert = UIAlertController(title: "Location Required",
                                      message: "Location is required, please enable Location in the Settings app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to Settings now", style: .default, handler: { (_: UIAlertAction) in
          print("")
          
          UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: { (finished) in
            print(finished)
            print("Finished")
          })
        }))
        UIApplication.shared.keyWindow!.rootViewController?.present(alert, animated: true, completion: nil)
      }
    } else if status == .authorizedWhenInUse {
      if !CLLocationManager.locationServicesEnabled() {
        // Location services is not available
        return
      }
      if let location = DataStore.shared.lastLocation {
        self.validateLocation(location: location)
      } else {
        DataStore.shared.startReceivingLocationChanges()
      }
    }
  }
  
}

// MARK: - Life Cycle
extension GetStartedLocationViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    DataStore.shared.delegate = self
    
    self.stylize()
  }
  
  func stylize() {
    self.enableLocationButton.stylizeDark()
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabel()
  }
  
}

extension GetStartedLocationViewController: DataStoreLocationDelegate {
  
  func firstLocationReceived(location: CLLocationCoordinate2D) {
    print("firstLocationReceived")
    self.validateLocation(location: location)
  }
  
  func authorizationStatusChanged(status: CLAuthorizationStatus) {
    print("authorization status changed; handling new status \(status)")
    self.handleAuthorizationStatus(status: status)
  }

}
