//
//  LandingScreenWaitlistViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/18/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import UserNotifications
import SwiftyJSON

class LandingScreenWaitlistViewController: UIViewController {
  
  @IBOutlet weak var notificationButtonImage: UIImageView!
  @IBOutlet weak var notificationsButton: UIButton!
  @IBOutlet weak var waitlistLabel: UILabel!
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> LandingScreenWaitlistViewController? {
    guard let landingScreenWaitlistVC = R.storyboard.landingScreenWaitlistViewController()
      .instantiateInitialViewController() as? LandingScreenWaitlistViewController else {
      print("Failed to create landing screen waitlist VC")
      return nil
    }
    return landingScreenWaitlistVC
  }
  
  @IBAction func notificationsButtonClicked(_ sender: Any) {
    DataStore.shared.getNotificationAuthorizationStatus { (status) in
      switch status {
      case .notDetermined, .provisional, .authorized:
        UNUserNotificationCenter.current()
          .requestAuthorization(
          options: [.badge, .alert, .sound]) { (granted, error) in
            print("Permission granted: \(granted)")
            if granted {
              DataStore.shared.registerForRemoteNotificationsIfAuthorized()
            }
            DispatchQueue.main.sync {
              if let error = error {
                print(error)
              }
              
              self.stylizeNotificationButton()
            }
        }
      case .denied:
        DispatchQueue.main.async {
          let alert = UIAlertController(title: "Location Required",
                                        message: "Location is required, please enable Location in the Settings app.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Go to Settings now", style: .default, handler: { (_: UIAlertAction) in
            DispatchQueue.main.async {
              UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: { (finished) in
                print(finished)
                print("Finished")
              })
              self.stylizeNotificationButton()
            }
          }))
          UIApplication.shared.keyWindow!.rootViewController?.present(alert, animated: true, completion: nil)
        }
      default:
        print("Unknown state")
      }
      
    }

  }
  
  func stylizeNotificationButton() {
    DataStore.shared.getNotificationAuthorizationStatus { (status) in
      DispatchQueue.main.async {
        if status == .authorized {
          self.notificationButtonImage.image = R.image.notificationsEnabledCheck()
        } else {
          self.notificationButtonImage.image = nil
        }
      }
    }
  }
  
}

// MARK: - Life Cycle
extension LandingScreenWaitlistViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.stylizeNotificationButton()
    DataStore.shared.getWaitlistNumber { (userCount) in
      DispatchQueue.main.async {
        self.waitlistLabel.text = "\(userCount) people waiting to Pear in Boston"
      }
    }
  }

  func stylize() {
    self.view.backgroundColor = UIColor(red: 1.00, green: 0.94, blue: 0.40, alpha: 1.00)
    self.notificationsButton.backgroundColor = UIColor.white
    self.notificationsButton.setTitleColor(UIColor.black, for: .normal)
    self.notificationsButton.layer.cornerRadius = 25
    self.notificationsButton.layer.shadowRadius = 2
    self.notificationsButton.layer.shadowOffset = CGSize(width: 1, height: 1)
    self.notificationsButton.layer.shadowColor = UIColor.black.cgColor
    self.notificationsButton.layer.shadowOpacity = 0.2
    
  }
}
