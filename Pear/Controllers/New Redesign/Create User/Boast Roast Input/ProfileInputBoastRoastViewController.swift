//
//  ProfileInputBoastRoastViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfileInputBoastRoastViewController: UIViewController {
  
  @IBOutlet weak var boastButton: UIButton!
  @IBOutlet weak var roastButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var doneButtonBottomConstraint: NSLayoutConstraint!
  
  enum BoastRoastMode {
    case boast
    case roast
  }
  
  var mode: BoastRoastMode = .boast
  var profileData: ProfileCreationData!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(profileCreationData: ProfileCreationData) -> ProfileInputBoastRoastViewController? {
    guard let profileRoastBoast = R.storyboard.profileInputBoastRoastViewController()
      .instantiateInitialViewController() as? ProfileInputBoastRoastViewController else { return nil }
    profileRoastBoast.profileData = profileCreationData
    return profileRoastBoast
  }
  
  @IBAction func selectedCategoryButton(_ sender: UIButton) {
    if sender.tag == 2 {
      self.mode = .boast
    } else if sender.tag == 3 {
      self.mode = .roast
    }
    self.stylizeBoastRoastButtons()
  }
}

// MARK: - Life Cycle
extension ProfileInputBoastRoastViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  func stylize() {
    self.view.backgroundColor = R.color.backgroundColorBlue()
    if let font = R.font.openSansExtraBold(size: 16) {
      self.titleLabel.font = font
    }
    self.titleLabel.textColor = UIColor.white

    guard let font = R.font.openSansExtraBold(size: 24) else {
      print("Failed to find font")
      return
    }
    self.boastButton.setAttributedTitle(
      NSAttributedString(string: "Boast them",
                         attributes: [NSAttributedString.Key.font: font,
                                      NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                      NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.5) ]),
      for: .selected)
    
    self.boastButton.setAttributedTitle(
      NSAttributedString(string: "Boast them",
                         attributes: [NSAttributedString.Key.font: font,
                                      NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 1.0) ]),
      for: .normal)
    
    self.roastButton.setAttributedTitle(
      NSAttributedString(string: "roast them",
                         attributes: [NSAttributedString.Key.font: font,
                                      NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                      NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.5) ]),
      for: .selected)
    
    self.roastButton.setAttributedTitle(
      NSAttributedString(string: "roast them",
                         attributes: [NSAttributedString.Key.font: font,
                                      NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 1.0) ]),
      for: .normal)
    self.stylizeBoastRoastButtons()
  }
  
  func setup() {
    
  }
  
  func stylizeBoastRoastButtons() {
    switch self.mode {
    case .boast:
      self.boastButton.isSelected = true
      self.roastButton.isSelected = false
    case .roast:
      self.boastButton.isSelected = false
      self.roastButton.isSelected = true
    }
    
  }
  
}

// MARK: - Dismiss First Responder on Click
extension ProfileInputBoastRoastViewController {
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileInputBoastRoastViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.view.endEditing(true)
  }
}

// MARK: - Keybaord Size Notifications
extension ProfileInputBoastRoastViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(ProfileInputBoastRoastViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(ProfileInputBoastRoastViewController.keyboardWillHide(notification:)),
                   name: UIWindow.keyboardWillHideNotification,
                   object: nil)
  }
  
  @objc func keyboardWillChange(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
      let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let targetFrame = targetFrameNSValue.cgRectValue
      self.doneButtonBottomConstraint.constant = targetFrame.height - self.view.safeAreaInsets.bottom + 20.0
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  @objc func keyboardWillHide(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      self.doneButtonBottomConstraint.constant = 20.0
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
}
