//
//  DiscoverySetupViewController.swift
//  Pear
//
//  Created by Lorenzo Bernaschina on 24/04/2019.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import CoreLocation

public class DiscoverySetupViewController: UIViewController {
  @IBOutlet weak var joinMessageLabel: UILabel!
  @IBOutlet weak var enableLocationButton: UIButton!
  @IBOutlet weak var finishSetupButton: UIButton!
  
  class func instantiate() -> DiscoverySetupViewController? {
    let storyboard = UIStoryboard(name: String(describing: DiscoverySetupViewController.self), bundle: nil)
    guard let discoverySetupVC = storyboard.instantiateInitialViewController() as? DiscoverySetupViewController else { return nil }
    return discoverySetupVC
  }
    
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    self.enableLocationButton.layer.cornerRadius = self.enableLocationButton.bounds.height/2
    self.finishSetupButton.layer.cornerRadius = self.finishSetupButton.bounds.height/2
    
    if CLLocationManager.locationServicesEnabled() {
      switch CLLocationManager.authorizationStatus() {
      case .notDetermined, .restricted, .denied:
        self.enableLocationButton.isEnabled = true
      case .authorizedAlways, .authorizedWhenInUse:
        self.enableLocationButton.isEnabled = false
        self.enableLocationButton.alpha = 0.3
      default:
         self.enableLocationButton.isEnabled = true
      }
    } else {
      self.enableLocationButton.isEnabled = true
    }
  }
  
  @IBAction func enableLocationButtonPressed(_ sender: Any) {
    DataStore.shared.locationManager.requestWhenInUseAuthorization()
  }
    
}

