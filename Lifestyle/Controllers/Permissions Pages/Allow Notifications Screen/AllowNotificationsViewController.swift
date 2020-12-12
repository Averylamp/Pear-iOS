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
    DataStore.shared.getNotificationAuthorizationStatus { (status) in
      switch status {
      case .denied:
        DispatchQueue.main.async {
          UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: { (finished) in
            print(finished)
            print("Finished")
          })
        }
      case .notDetermined, .provisional:
        self.requestNotificaionAuthorization()
      case .authorized:
        Analytics.logEvent("enable_notifications", parameters: nil)
        // register for remote notifications
        DataStore.shared.registerForRemoteNotificationsIfAuthorized()
        self.continueToOnboardingOrMain()
      default:
        self.requestNotificaionAuthorization()
      }
    }
    
  }
  
  func requestNotificaionAuthorization() {
    UNUserNotificationCenter.current()
      .requestAuthorization(
      options: [.badge, .alert, .sound]) { (granted, _) in
        print("Permission granted: \(granted)")
        if granted {
          Analytics.logEvent("enable_notifications", parameters: nil)
          // register for remote notifications
          DataStore.shared.registerForRemoteNotificationsIfAuthorized()
          self.continueToOnboardingOrMain()
        } else {
          DataStore.shared.getNotificationAuthorizationStatus(completion: { (status) in
            self.stylizeForNotificationStatus(status: status)
          })
        }
    }
  }
  
  @IBAction func skipNotificationsClicked(_ sender: Any) {
    self.continueToOnboardingOrMain()
  }

  func stylizeForNotificationStatus(status: UNAuthorizationStatus) {
    DispatchQueue.main.async {
      switch status {
      case .denied:
        self.enableNotificationsButton.setTitle("Open Settings", for: .normal)
      case .notDetermined, .provisional:
        self.enableNotificationsButton.setTitle("Enable Notifications", for: .normal)
      case .authorized:
        self.enableNotificationsButton.setTitle("Continue", for: .normal)
      default:
        self.enableNotificationsButton.setTitle("Enable Notifications", for: .normal)
      }
    }
  }
}

// MARK: - Life Cycle
extension AllowNotificationsViewController {
  
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
    DataStore.shared.getNotificationAuthorizationStatus { (status) in
      if status == .denied {
        DispatchQueue.main.async {
          self.enableNotificationsButton.setTitle("Open Settings", for: .normal)
        }
      }
    }
  }
  
}
