//
//  UserEmailInfoViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/15/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import CoreLocation

class UserEmailInfoViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var phoneNumberContainerView: UIView!
  @IBOutlet weak var phoneNumberInputTextField: UITextField!
  @IBOutlet weak var emailContainerView: UIView!
  @IBOutlet weak var emailInputTextField: UITextField!
  @IBOutlet weak var subtextLabelBottomConstraint: NSLayoutConstraint!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserEmailInfoViewController? {
    guard let emailInfoVC = R.storyboard.userEmailInfoViewController().instantiateInitialViewController() as? UserEmailInfoViewController else { return nil }
    
    return emailInfoVC
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    if let email = self.emailInputTextField.text,
      email.count > 3, email.contains("@"),
      let userID = DataStore.shared.currentPearUser?.documentID {
      PearUserAPI.shared.updateUser(userID: userID, updates: [
        "email": email]) { (result) in
        switch result {
        case .success(let successful):
          if successful {
            print("Successfully updated email")
          } else {
            print("Failed to update email")
          }
        case .failure(let error):
          print("Failed to update email: \(error)")
        }
      }
    }
    let locationStatus = CLLocationManager.authorizationStatus()
    if locationStatus != .authorizedWhenInUse && locationStatus != .authorizedAlways {
      guard let locationAuthorizationVC = AllowLocationViewController.instantiate() else {
        print("Unable to create Location Auth VC")
        return
      }
      self.navigationController?.setViewControllers([locationAuthorizationVC], animated: true)
      return
    }
    DataStore.shared.withinBostonArea { (withinBoston) in
      if let withinBoston = withinBoston {
        if withinBoston  || DataStore.shared.fetchFlagFromDefaults(flag: .hasBeenInBostonArea) {
          DataStore.shared.setFlagToDefaults(value: true, flag: .hasBeenInBostonArea)
          self.continueToNotificationsPageIfNotEnabled()
        } else {
          self.continueToLocationBlockedPage()
        }
      } else {
        DataStore.shared.locationDelegate = self
        DataStore.shared.firstLocationReceived = false
        DataStore.shared.startReceivingLocationChanges()
      }
    }
  }
  
  func continueToNotificationsPageIfNotEnabled() {
    DataStore.shared.getNotificationAuthorizationStatus { (status) in
      if status != .authorized {
        self.continueToAllowNotifications()
        return
      } else {
        if DataStore.shared.fetchFlagFromDefaults(flag: .hasCompletedOnboarding) {
          self.continueToMainVC()
        } else {
          self.continueToOnboarding()
        }
        return
      }
    }
  }
}

// MARK: - Permissions Flow Protocol
extension UserEmailInfoViewController: PermissionsFlowProtocol {
  // No-Op
}

// MARK: - First Location Delegate Manager
extension UserEmailInfoViewController: DataStoreLocationDelegate {
  func firstLocationReceived(location: CLLocationCoordinate2D) {
    DataStore.shared.withinBostonArea { (withinBoston) in
      if let withinBoston = withinBoston {
        if withinBoston   || DataStore.shared.fetchFlagFromDefaults(flag: .hasBeenInBostonArea) {
          DataStore.shared.setFlagToDefaults(value: true, flag: .hasBeenInBostonArea)
          self.continueToNotificationsPageIfNotEnabled()
        } else {
          self.continueToLocationBlockedPage()
        }
      }
    }
  }
  
  func authorizationStatusChanged(status: CLAuthorizationStatus) {
    // no-op
  }
  
}

// MARK: - Life Cycle
extension UserEmailInfoViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
    self.addKeyboardNotifications(animated: true)
    self.addKeyboardDismissOnTap()
  }
  
  func stylize() {
    self.titleLabel.stylizeOnboardingTitleLabel()
    self.phoneNumberContainerView.layer.cornerRadius = 12
    self.emailContainerView.layer.cornerRadius = 12
    self.emailContainerView.layer.borderWidth = 1
    self.emailContainerView.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    self.continueButton.layer.cornerRadius = self.continueButton.frame.height / 2.0
  }
  
  func setup() {
    guard let phoneNumber = DataStore.shared.currentPearUser?.phoneNumber else {
      print("Failed to get phone number")
      return
    }
    self.phoneNumberInputTextField.text = String.formatPhoneNumber(phoneNumber: phoneNumber)
    
  }
  
}

// MARK: - KeyboardEventsBottomProtocol
extension UserEmailInfoViewController: KeyboardEventsBottomProtocol {
  
  var bottomKeyboardConstraint: NSLayoutConstraint? {
    return self.subtextLabelBottomConstraint
  }
  
  var bottomKeyboardPadding: CGFloat {
    return 20.0
  }
  
}

// MARK: - KeyboardEventsDismissTapProtocol
extension UserEmailInfoViewController: KeyboardEventsDismissTapProtocol {
  func addKeyboardDismissOnTap() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserEmailInfoViewController.backgroundViewTapped)))
  }
  
  @objc func backgroundViewTapped() {
    self.dismissKeyboard()
  }
}
