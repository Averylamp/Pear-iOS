//
//  UpdateUserPreferencesViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/2/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UpdateUserPreferencesViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var nextButton: UIButton!
  
  weak var genderPreferencesVC: UserGenderPreferencesViewController?
  weak var agePreferenceVC: UserAgePreferencesViewController?
  @IBOutlet weak var bottomButtonBottomConstraint: NSLayoutConstraint!
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UpdateUserPreferencesViewController? {
    let storyboard = UIStoryboard(name: String(describing: UpdateUserPreferencesViewController.self), bundle: nil)
    guard let updatePreferencesVC = storyboard.instantiateInitialViewController() as? UpdateUserPreferencesViewController else { return nil }
    
    return updatePreferencesVC
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
}

// MARK: - Life Cycle
extension UpdateUserPreferencesViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setupUserPreferences()
    self.addKeyboardSizeNotifications()
    self.addDismissKeyboardOnViewClick()
   }
  
  func stylize() {
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabel()
    self.nextButton.stylizeDark()
  }

  func setupUserPreferences() {
    
    guard let currentUser = DataStore.shared.currentPearUser else {
      print("Failed to fetch user")
      return
    }
    
    var genderPreferences = currentUser.matchingPreferences.seekingGender
    if genderPreferences.count == 0,
      let currentGender = currentUser.gender {
      if currentGender == .male {
        genderPreferences.append(.female)
      } else if currentGender == .female {
        genderPreferences.append(.male)
      } else if currentGender == .nonbinary {
        genderPreferences = [.male, .female, .nonbinary]
      }
    }
    
    guard let userGenderPreferencesVC = UserGenderPreferencesViewController.instantiate(genderPreferences: genderPreferences) else {
      print("Unable to instantiate user gender preferences vc")
      return
    }
    stackView.addArrangedSubview(userGenderPreferencesVC.view)
    self.addChild(userGenderPreferencesVC)
    self.genderPreferencesVC = userGenderPreferencesVC
    userGenderPreferencesVC.didMove(toParent: self)
    
    guard let agePreferencesVC = UserAgePreferencesViewController
      .instantiate(minAge: currentUser.matchingPreferences.minAgeRange,
                   maxAge: currentUser.matchingPreferences.maxAgeRange) else {
      print("Unable to instantiate user gender preferences vc")
      return
    }
    stackView.addArrangedSubview(agePreferencesVC.view)
    self.addChild(agePreferencesVC)
    self.agePreferenceVC = agePreferencesVC
    agePreferencesVC.didMove(toParent: self)
    
  }
  
}

// MARK: - Keybaord Size Notifications
extension UpdateUserPreferencesViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(UpdateUserPreferencesViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(UpdateUserPreferencesViewController.keyboardWillHide(notification:)),
                   name: UIWindow.keyboardWillHideNotification,
                   object: nil)
  }
  
  @objc func keyboardWillChange(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
      let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let targetFrame = targetFrameNSValue.cgRectValue
      let keyboardBottomPadding: CGFloat = 20
      self.bottomButtonBottomConstraint.constant = targetFrame.size.height - self.view.safeAreaInsets.bottom + keyboardBottomPadding
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
  @objc func keyboardWillHide(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      let keyboardBottomPadding: CGFloat = 20
      self.bottomButtonBottomConstraint.constant = keyboardBottomPadding
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
}

// MARK: - Dismiss First Responder on Click
extension UpdateUserPreferencesViewController {
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UpdateUserPreferencesViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.view.endEditing(true)
  }
}
