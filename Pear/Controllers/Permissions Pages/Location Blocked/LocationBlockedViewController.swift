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
    guard let locationBlockedVC = R.storyboard.locationBlockedViewController
      .instantiateInitialViewController()  else {
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
        DataStore.shared.getNotificationAuthorizationStatus { (status) in
          self.stylizeForNotificationStatus(status: status)
        }
    } 
  }
  
  func stylizeForNotificationStatus(status: UNAuthorizationStatus) {
    DispatchQueue.main.async {
      switch status {
      case .denied:
        self.enableNotificationsButton.setTitle("Open Settings", for: .normal)
      case .notDetermined, .provisional:
        self.enableNotificationsButton.setTitle("Enable Notifications", for: .normal)
      case .authorized:
        self.enableNotificationsButton.setTitle("You're all set!", for: .normal)
      default:
        self.enableNotificationsButton.setTitle("Enable Notifications", for: .normal)
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    DataStore.shared.getNotificationAuthorizationStatus { (status) in
      self.stylizeForNotificationStatus(status: status)
    }
  }
  
  func stylize() {
    
    self.titleLabel.stylizeUserSignupTitleLabel()
    self.subtitleLabel.stylizeUserSignupSubtitleLabel()
    self.enableNotificationsButton.stylizeDark()
  }
  
}
