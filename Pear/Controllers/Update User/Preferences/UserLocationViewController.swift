//
//  UserLocationViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/2/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import CoreLocation

class UserLocationViewController: UIViewController {

  var locationName: String?
  var locationCoordinate: CLLocationCoordinate2D?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(locationName: String?, locationCoordinates: CLLocationCoordinate2D?) -> UserLocationViewController? {
    let storyboard = UIStoryboard(name: String(describing: UserLocationViewController.self), bundle: nil)
    guard let locationPrefVC = storyboard.instantiateInitialViewController() as? UserLocationViewController else { return nil }
    locationPrefVC.locationName = locationName
    locationPrefVC.locationCoordinate = locationCoordinates
    return locationPrefVC
  }
  
}

// MARK: - Life Cycle
extension UserLocationViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    
  }
  
}
