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

class AllowNotificationsViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  @IBOutlet weak var enableNotificationsButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> AllowNotificationsViewController? {
    let storyboard = UIStoryboard(name: String(describing: AllowNotificationsViewController.self), bundle: nil)
    guard let allowNotificationsVC = storyboard.instantiateInitialViewController() as? AllowNotificationsViewController else { return nil }
    return allowNotificationsVC
  }
  
  @IBAction func enableNotificationsClicked(_ sender: Any) {
    UNUserNotificationCenter.current()
      .requestAuthorization(
      options: [.badge, .alert, .sound]) { (granted, _) in
        print("Permission granted: \(granted)")
        if granted {
          // register for remote notifications
          DataStore.shared.registerForRemoteNotificationsIfAuthorized()
          self.continueToOnboardingOrMain()
        }
    }
    
  }
  
  @IBAction func skipNotificationsClicked(_ sender: Any) {
    self.continueToOnboardingOrMain()
  }
  
  func continueToOnboardingOrMain() {
    DispatchQueue.main.async {
      if DataStore.shared.fetchFlagFromDefaults(flag: .hasCompletedOnboarding) {
        guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
          print("Failed to initialize main VC")
          return
        }
        self.navigationController?.setViewControllers([mainVC], animated: true)
      } else {
//        guard let onboardingVC =
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
  
  func stylize() {
    self.titleLabel.stylizeOnboardingTitleLabel()
    self.subtitleLabel.stylizeOnboardingSubtitleLabel()
  }
  
}
