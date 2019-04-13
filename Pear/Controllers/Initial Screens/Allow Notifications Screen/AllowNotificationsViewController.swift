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
      options: [.badge, .alert, .sound]) { (granted, _) in
        print("Permission granted: \(granted)")
        if granted {
          // register for remote notifications
          DataStore.shared.registerForRemoteNotificationsIfAuthorized()
        }
        let locationAuthStatus = CLLocationManager.authorizationStatus()
        if locationAuthStatus == .authorizedWhenInUse || locationAuthStatus == .authorizedAlways {
          DispatchQueue.main.async {
            guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
              print("Failed to create Main Screen VC")
              return
            }
            self.navigationController?.setViewControllers([mainVC], animated: true)
          }
        } else {
          if let allowLocationVC = AllowLocationViewController.instantiate() {
            DispatchQueue.main.async {
              self.navigationController?.pushViewController(allowLocationVC, animated: true)
            }
          } else {
            print("Failed to create Allow Location VC")
          }
        }
    }
    
  }
  
  @IBAction func skipNotificationsClicked(_ sender: Any) {
    DispatchQueue.main.async {
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
