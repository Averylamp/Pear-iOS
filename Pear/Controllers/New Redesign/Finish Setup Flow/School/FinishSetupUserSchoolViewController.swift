//
//  FinishSetupUserSchoolViewController.swift
//  Pear
//
//  Created by Brian Gu on 4/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import BSImagePicker
import Photos
import FirebaseAnalytics

class FinishSetupUserSchoolViewController: UIViewController {
  
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var schoolNameTextField: UITextField!
  @IBOutlet weak var schoolNameContainer: UIView!
  @IBOutlet weak var schoolNameTitle: UILabel!
  
  @IBOutlet weak var bottomButtonBottomConstraint: NSLayoutConstraint!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> FinishSetupUserSchoolViewController? {
    let storyboard = UIStoryboard(name: String(describing: FinishSetupUserSchoolViewController.self), bundle: nil)
    guard let schoolInputVC = storyboard.instantiateInitialViewController() as? FinishSetupUserSchoolViewController else { return nil }
    return schoolInputVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    
    let schoolName = self.schoolNameTextField.text == "" ? nil : self.schoolNameTextField.text!
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Failed to get Current User")
      return
    }
    self.nextButton.isEnabled = false
    self.nextButton.alpha = 0.3
    PearUserAPI.shared.updateUserSchool(userID: userID,
                                        schoolName: schoolName,
                                        schoolYear: nil) { (result) in
                                          switch result {
                                          case .success(let successful):
                                            if successful {
                                              print("Update user school was successful")
                                            } else {
                                              print("Update user school was unsuccessful")
                                            }
                                            self.continueToBirthdateScreen()
                                          case .failure(let error):
                                            print("Update user failure: \(error)")
                                          }
                                          DispatchQueue.main.async {
                                            self.nextButton.isEnabled = true
                                            self.nextButton.alpha = 1.0
                                          }
    }
  }
  
  @IBAction func skipButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    DispatchQueue.main.async {
      guard let birthdateVC = FinishSetupUserBirthdateViewController.instantiate() else {
        print("Failed to initialize birthdate VC")
        return
      }
      self.navigationController?.pushViewController(birthdateVC, animated: true)
      Analytics.logEvent("FS_school_TAP_skip", parameters: nil)
    }
  }
  
  func continueToBirthdateScreen() {
    DispatchQueue.main.async {
      guard let birthdateVC = FinishSetupUserBirthdateViewController.instantiate() else {
        print("Failed to initialize birthdate VC")
        return
      }
      self.navigationController?.pushViewController(birthdateVC, animated: true)
    }
  }
  
}

// MARK: - Life Cycle
extension FinishSetupUserSchoolViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    
    self.addKeyboardSizeNotifications()
    self.addDismissKeyboardOnViewClick()
  }
  
  func stylize() {
    self.nextButton.stylizePreferencesOn()
    self.skipButton.stylizeSubtle()
    
    self.view.layoutIfNeeded()
    
    self.schoolNameContainer.stylizeInputTextFieldContainer()
    self.schoolNameTitle.stylizeTextFieldTitle()
    self.schoolNameTextField.stylizeInputTextField()
    self.schoolNameTextField.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.view.layoutIfNeeded()
    UIView.animate(withDuration: StylingConfig.progressBarAnimationDuration, delay: StylingConfig.progressBarAnimationDelay, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
}

// MARK: - Text Field Delegate
extension FinishSetupUserSchoolViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == self.schoolNameTextField {
      self.nextButtonClicked(self.nextButton as Any)
    }
    return false
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return true
  }
  
}

// MARK: - Keybaord Size Notifications
extension FinishSetupUserSchoolViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(FinishSetupUserSchoolViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(FinishSetupUserSchoolViewController.keyboardWillHide(notification:)),
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
extension FinishSetupUserSchoolViewController {
  
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FinishSetupUserSchoolViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.schoolNameTextField.resignFirstResponder()
  }
  
}
