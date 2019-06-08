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
import FirebaseAnalytics

class AllowNotificationsViewController: OnboardingViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  @IBOutlet weak var enableNotificationsButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> AllowNotificationsViewController? {
    guard let allowNotificationsVC = R.storyboard.allowNotificationsViewController
      .instantiateInitialViewController()  else { return nil }
    return allowNotificationsVC
  }
  
  @IBAction func enableNotificationsClicked(_ sender: Any) {
    UNUserNotificationCenter.current()
      .requestAuthorization(
      options: [.badge, .alert, .sound]) { (granted, _) in
        print("Permission granted: \(granted)")
        if granted {
          Analytics.logEvent("enable_notifications", parameters: nil)
          // register for remote notifications
          DataStore.shared.registerForRemoteNotificationsIfAuthorized()
          self.continueToOnboardingOrMain()
        }
    }
    DataStore.shared.getNotificationAuthorizationStatus { (status) in
      if status == .denied {
        DispatchQueue.main.async {
          UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: { (finished) in
            print(finished)
            print("Finished")
          })
        }
      }
    }
    
  }
  
  @IBAction func skipNotificationsClicked(_ sender: Any) {
    self.continueToOnboardingOrMain()
  }
}

// MARK: - Life Cycle
extension AllowNotificationsViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    self.titleLabel.stylizeUserSignupTitleLabel()
    self.subtitleLabel.stylizeUserSignupSubtitleLabel()
    self.enableNotificationsButton.stylizeDark()
    DataStore.shared.getNotificationAuthorizationStatus { (status) in
      if status == .denied {
        DispatchQueue.main.async {
          self.enableNotificationsButton.setTitle("Open Settings", for: .normal)
        }
      }
    }
  }
  
}
