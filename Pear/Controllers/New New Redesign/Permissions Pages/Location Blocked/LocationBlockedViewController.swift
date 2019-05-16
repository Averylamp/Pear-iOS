//
//  AllowNotificationsViewController.swift
//  Pear
//
//  Created by Brian Gu on 4/13/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

class LocationBlockedViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  @IBOutlet weak var enableNotificationsButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> LocationBlockedViewController? {
    guard let locationBlockedVC = R.storyboard.locationBlockedViewController()
      .instantiateInitialViewController() as? LocationBlockedViewController else {
        return nil
    }
    return locationBlockedVC
  }
  
  @IBAction func enableNotificationsClicked(_ sender: Any) {
    UNUserNotificationCenter.current()
      .requestAuthorization(
      options: [.badge, .alert, .sound]) { (granted, _) in
        print("Permission granted: \(granted)")
        if granted {
          // register for remote notifications
          DataStore.shared.registerForRemoteNotificationsIfAuthorized()
        }
    }
    
  }
  
}

// MARK: - Life Cycle
extension LocationBlockedViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.stylize()
    
  }
  
  func stylize() {
    
    self.titleLabel.stylizeOnboardingTitleLabel()
    self.subtitleLabel.stylizeOnboardingSubtitleLabel()
    
  }
  
}
