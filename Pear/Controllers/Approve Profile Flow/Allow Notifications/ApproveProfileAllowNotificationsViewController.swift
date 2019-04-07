//
//  ApproveProfileAllowNotificationsViewController.swift
//  Pear
//
//  Created by Brian Gu on 4/7/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import UserNotifications

class ApproveProfileAllowNotificationsViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  @IBOutlet weak var enableNotificationsButton: UIButton!
  @IBOutlet weak var skipButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> ApproveProfileAllowNotificationsViewController? {
    let storyboard = UIStoryboard(name: String(describing: ApproveProfileAllowNotificationsViewController.self), bundle: nil)
    guard let allowNotificationsVC = storyboard.instantiateInitialViewController() as? ApproveProfileAllowNotificationsViewController else { return nil }
    return allowNotificationsVC
  }
  
  @IBAction func enableNotificationsClicked(_ sender: Any) {
    UNUserNotificationCenter.current()
      .requestAuthorization(
      options: [.badge, .alert, .sound]) { (granted, error) in
        print("Permission granted: \(granted)")
        if granted {
          // register for remote notifications
          DataStore.shared.registerForRemoteNotificationsIfAuthorized()
        }
        DispatchQueue.main.sync {
          if let error = error {
            print(error)
          }
          self.dismiss(animated: true, completion: nil)
        }
    }
    
  }
  
  @IBAction func skipNotificationsClicked(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
}

// MARK: - Life Cycle
extension ApproveProfileAllowNotificationsViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.stylize()
    
  }
  
  func stylize() {
    self.enableNotificationsButton.stylizeDark()
    self.skipButton.stylizeSubtle()
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabel()
    self.subtitleLabel.text = "You'll be notified when you receive new matches, and more!"
    
  }
  
}
