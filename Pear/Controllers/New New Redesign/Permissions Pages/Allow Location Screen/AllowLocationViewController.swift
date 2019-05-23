//
//  AllowLocationViewController.swift
//  Pear
//
//  Created by Brian Gu on 3/29/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import CoreLocation

// if you're logging in and have a PearUser assigned to you, but for whatever reason don't have location authorized
// After you complete the flow of this VC, you're taken to the main VC
class AllowLocationViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  @IBOutlet weak var enableLocationButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> AllowLocationViewController? {
    guard let allowLocationVC = R.storyboard.allowLocationViewController()
      .instantiateInitialViewController() as? AllowLocationViewController else { return nil }
    return allowLocationVC
  }
  
  @IBAction func enableLocationClicked(_ sender: Any) {
    let status = CLLocationManager.authorizationStatus()
    self.handleAuthorizationStatus(status: status)
  }
  
  func handleAuthorizationStatus(status: CLAuthorizationStatus) {
    if status == .notDetermined {
      DataStore.shared.locationManager.requestWhenInUseAuthorization()
    } else if status == .denied {
      DispatchQueue.main.async {
        let alert = UIAlertController(title: "Location Required",
                                      message: "Location is required, please enable Location in the Settings app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to Settings now", style: .default, handler: { (_: UIAlertAction) in
          UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: { (finished) in
            print(finished)
            print("Finished")
          })
        }))
        UIApplication.shared.keyWindow!.rootViewController?.present(alert, animated: true, completion: nil)
      }
    } else if status == .authorizedWhenInUse {
      if !CLLocationManager.locationServicesEnabled() {
        // Location services is not available on the DEVICE
        return
      }
      DataStore.shared.withinBostonArea { (withinBoston) in
        if let withinBoston = withinBoston {
          if withinBoston  || DataStore.shared.fetchFlagFromDefaults(flag: .hasBeenInBostonArea) {
            DataStore.shared.setFlagToDefaults(value: true, flag: .hasBeenInBostonArea)
            self.continueToNotificationOrNext()
          } else {
            self.continueToLocationBlockedPage()
          }
        } else {
          DataStore.shared.locationDelegate = self
          DataStore.shared.firstLocationReceived = false
          DataStore.shared.startReceivingLocationChanges()
        }
      }
    }
  }
  
}

// MARK: - Permissions Flow Protocol
extension AllowLocationViewController: PermissionsFlowProtocol {
  // No-Op
}

// MARK: - Life Cycle
extension AllowLocationViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    DataStore.shared.locationDelegate = self
    self.stylize()
  }
  
  func stylize() {
    self.enableLocationButton.stylizeDark()
    self.titleLabel.stylizeUserSignupTitleLabel()
    self.subtitleLabel.stylizeUserSignupSubtitleLabel()
    let status = CLLocationManager.authorizationStatus()
    if status == .denied {
      self.enableLocationButton.setTitle("Open Settings", for: .normal)
    }
  }
  
}

extension AllowLocationViewController: DataStoreLocationDelegate {
  
  func firstLocationReceived(location: CLLocationCoordinate2D) {
    DataStore.shared.withinBostonArea { (withinBoston) in
      if let withinBoston = withinBoston {
        if withinBoston   || DataStore.shared.fetchFlagFromDefaults(flag: .hasBeenInBostonArea) {
          DataStore.shared.setFlagToDefaults(value: true, flag: .hasBeenInBostonArea)
          self.self.continueToNotificationOrNext()
        } else {
          self.continueToLocationBlockedPage()
        }
      }
    }
  }
  
  func authorizationStatusChanged(status: CLAuthorizationStatus) {
    print("authorization status changed; handling new status \(status)")
    self.handleAuthorizationStatus(status: status)
  }
  
}
