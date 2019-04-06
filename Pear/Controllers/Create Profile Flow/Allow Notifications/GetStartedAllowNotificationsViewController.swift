//
//  GetStartedAllowNotificationsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/28/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import UserNotifications

class GetStartedAllowNotificationsViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  @IBOutlet weak var enableNotificationsButton: UIButton!
  @IBOutlet weak var skipButton: UIButton!
  
  var friendName: String?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(friendName: String? = nil) -> GetStartedAllowNotificationsViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedAllowNotificationsViewController.self), bundle: nil)
    guard let allowNotificationsVC = storyboard.instantiateInitialViewController() as? GetStartedAllowNotificationsViewController else { return nil }
    allowNotificationsVC.friendName = friendName
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
    guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
      print("Failed to initialize main VC")
      return
    }
    self.navigationController?.setViewControllers([mainVC], animated: true)
  }
  
}

// MARK: - Life Cycle
extension GetStartedAllowNotificationsViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.stylize()
    
  }
  
  func stylize() {
    self.enableNotificationsButton.stylizeDark()
    self.skipButton.stylizeSubtle()
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabel()
    if let friendName = self.friendName {
      self.subtitleLabel.text = "You'll be able to pear \(friendName) with potential matches, and more!"
    }
    
  }
  
}
