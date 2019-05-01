//
//  DiscoverySetupViewController.swift
//  Pear
//
//  Created by Lorenzo Bernaschina on 24/04/2019.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAnalytics

public class DiscoverySetupViewController: UIViewController {
  @IBOutlet weak var joinMessageLabel: UILabel!
  @IBOutlet weak var enableLocationButton: UIButton!
  @IBOutlet weak var finishSetupButton: UIButton!
  
  var skippedDetachedProfiles: [String] = []
  
  class func instantiate() -> DiscoverySetupViewController? {
    let storyboard = UIStoryboard(name: String(describing: DiscoverySetupViewController.self), bundle: nil)
    guard let discoverySetupVC = storyboard.instantiateInitialViewController() as? DiscoverySetupViewController else { return nil }
    return discoverySetupVC
  }
    
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    DataStore.shared.locationManager.delegate = self
    
    self.enableLocationButton.layer.cornerRadius = self.enableLocationButton.bounds.height/2
    self.finishSetupButton.layer.cornerRadius = self.finishSetupButton.bounds.height/2
    
    if DataStore.shared.hasEnabledLocation() {
      self.setEnableLocationButton(forStatus: CLLocationManager.authorizationStatus())
    } else {
      self.enableLocationButton.isEnabled = true
    }
    
    self.finishSetupButton.isHidden = DataStore.shared.hasCompletedSetup()
    
    DataStore.shared.getWaitlistNumber { (userCount) in
      DispatchQueue.main.async {
        self.joinMessageLabel.text = "Join \(userCount) people pearing nearby"
      }
    }
    
    self.skippedDetachedProfiles = DataStore.shared.fetchListFromDefaults(type: .skippedDetachedProfiles)
    self.checkForDetachedProfiles()
  }
  
  @IBAction func enableLocationButtonPressed(_ sender: Any) {

    Analytics.logEvent("DISC_setup_TAP_enableLoc", parameters: nil)

    if CLLocationManager.authorizationStatus() == .notDetermined {
      DataStore.shared.locationManager.requestWhenInUseAuthorization()
    } else {
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
    }
  }
  
  @IBAction func finishSetupButtonPressed(_ sender: Any) {
    Analytics.logEvent("DISC_setup_TAP_finishSetup", parameters: nil)
    guard let setupGenderVC = FinishSetupUserGenderViewController.instantiate() else {
      print("Failed to create finish setup gender vc")
      return
    }
    print("finish setup button pressed")
    self.navigationController?.setViewControllers([setupGenderVC], animated: true)
  }
  
  private func setEnableLocationButton(forStatus status: CLAuthorizationStatus) {
    print("location auth status is:")
    print(status.rawValue)
    switch status {
    case .notDetermined, .restricted, .denied:
      self.enableLocationButton.isEnabled = true
    case .authorizedAlways, .authorizedWhenInUse:
      self.enableLocationButton.isEnabled = false
      self.enableLocationButton.alpha = 0.3
    default:
      self.enableLocationButton.isEnabled = true
    }
  }
  
  // copied from DiscoverySimpleViewController
  func checkForDetachedProfiles() {
    DataStore.shared.checkForDetachedProfiles(detachedProfilesFound: { (detachedProfiles) in
      print("\(detachedProfiles.count) Detached Profiles Found")
      for detachedProfile in detachedProfiles
        where !self.skippedDetachedProfiles.contains(detachedProfile.creatorUserID) {
          DispatchQueue.main.async {
            guard let detachedProfileApprovalVC = ApproveDetachedProfileNavigationViewController
              .instantiate(detachedProfile: detachedProfile) else {
                print("Failed to create detached profile navigation vc")
                return
            }
            self.present(detachedProfileApprovalVC, animated: true, completion: nil)
            return
          }
      }
    })
  }

}

extension DiscoverySetupViewController: CLLocationManagerDelegate {
  public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    print("location status did change")
    self.setEnableLocationButton(forStatus: CLLocationManager.authorizationStatus())
    guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
      print("Failed to initialize Main VC")
      return
    }
    self.navigationController?.setViewControllers([mainVC], animated: true)
  }
}
