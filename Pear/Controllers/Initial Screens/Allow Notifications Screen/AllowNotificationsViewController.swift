//
//  AllowNotificationsViewController.swift
//  Pear
//
//  Created by Brian Gu on 4/13/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import UserNotifications

class AllowNotificationsViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  @IBOutlet weak var enableNotificationsButton: UIButton!
  @IBOutlet weak var skipButton: UIButton!
  
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
          guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
            print("Failed to initialize main VC")
            return
          }
          self.navigationController?.setViewControllers([mainVC], animated: true)
        }
    }
    
  }
  
  @IBAction func skipNotificationsClicked(_ sender: Any) {
    DispatchQueue.main.sync {
      guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
        print("Failed to initialize main VC")
        return
      }
      self.navigationController?.setViewControllers([mainVC], animated: true)
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
    self.enableNotificationsButton.stylizeDark()
    self.skipButton.stylizeSubtle()
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabel()
    self.subtitleLabel.text = "You'll be notified when you receive new matches, and more!"
    
  }
  
}
