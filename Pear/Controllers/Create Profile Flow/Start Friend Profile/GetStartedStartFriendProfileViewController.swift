//
//  GetStartedFriendNameViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Firebase

class GetStartedStartFriendProfileViewController: UIViewController {
  
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var skipButton: UIButton!
  
  @IBOutlet weak var inputTextFieldContainerView: UIView!
  @IBOutlet weak var inputTextField: UITextField!
  @IBOutlet weak var inputTextFieldTitle: UILabel!
  
  var gettingStartedData: UserProfileCreationData!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  @IBOutlet weak var bottomButtonBottomConstraint: NSLayoutConstraint!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> GetStartedStartFriendProfileViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedStartFriendProfileViewController.self), bundle: nil)
    guard let startFriendProfileVC = storyboard.instantiateInitialViewController() as? GetStartedStartFriendProfileViewController else { return nil }
    startFriendProfileVC.gettingStartedData = UserProfileCreationData()
    #if DEVMODE
    startFriendProfileVC.gettingStartedData.fakePopulate()
    #endif
    return startFriendProfileVC
  }
  
  @discardableResult
  func saveProfileFirstName() -> String? {
    if let profileFirstName = inputTextField.text {
      self.gettingStartedData.firstName = profileFirstName
      return profileFirstName
    }
    return nil
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    if let endorseeFirstName = saveProfileFirstName() {
      if endorseeFirstName.count < 1 {
        self.alert(title: "Name Missing", message: "Please enter a friend's name")
        return
      }
      guard let chooseGenderVC = GetStartedChooseGenderViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
        print("Failed to create Gender VC")
        return
      }
      Analytics.logEvent("started_create_profile", parameters: nil)
      self.navigationController?.pushViewController(chooseGenderVC, animated: true)
    }
  }
  
  @IBAction func skipProfileCreationButtonClicked(_ sender: Any) {
    if let mainVC = LoadingScreenViewController.getMainScreenVC() {
      self.navigationController?.setViewControllers([mainVC], animated: true)
    }
  }
  
}

// MARK: - Life Cycle
extension GetStartedStartFriendProfileViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.addKeyboardSizeNotifications()
    self.addDismissKeyboardOnViewClick()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.dismissKeyboard()
    self.view.layoutIfNeeded()
  }
  
  func stylize() {
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabel()
    self.nextButton.stylizeDark()
    self.skipButton.stylizeSubtle()
    self.inputTextFieldContainerView.stylizeInputTextFieldContainer()
    self.inputTextFieldTitle.stylizeTextFieldTitle()
    self.inputTextField.stylizeInputTextField()
    
  }
  
}

// MARK: - Keybaord Size Notifications
extension GetStartedStartFriendProfileViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(GetStartedStartFriendProfileViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(GetStartedStartFriendProfileViewController.keyboardWillHide(notification:)),
                   name: UIWindow.keyboardWillHideNotification,
                   object: nil)
  }
  
  @objc func keyboardWillChange(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
      let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let targetFrame = targetFrameNSValue.cgRectValue
      var buttonHeight: CGFloat = self.skipButton.frame.origin.y + self.skipButton.frame.height - self.nextButton.frame.origin.y
      if self.view.frame.height > 600 {
        buttonHeight = self.skipButton.frame.height - 12
      }
      self.bottomButtonBottomConstraint.constant = targetFrame.size.height - self.view.safeAreaInsets.bottom - buttonHeight
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
extension GetStartedStartFriendProfileViewController {
  
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GetStartedStartFriendProfileViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.inputTextField.resignFirstResponder()
  }
  
}
