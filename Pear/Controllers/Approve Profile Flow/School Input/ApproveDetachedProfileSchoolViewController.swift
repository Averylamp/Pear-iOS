//
//  GetStartedPhotoInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import BSImagePicker
import Photos

class ApproveDetachedProfileSchoolViewController: UIViewController {
  
  var detachedProfile: PearDetachedProfile!
  
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
  let pageNumber: CGFloat = 1.0
  
  @IBOutlet weak var schoolNameTextField: UITextField!
  @IBOutlet weak var schoolNameContainer: UIView!
  @IBOutlet weak var schoolNameTitle: UILabel!

  @IBOutlet weak var schoolYearTextField: UITextField!
  @IBOutlet weak var schoolYearContainer: UIView!
  @IBOutlet weak var schoolYearTitle: UILabel!
  
  @IBOutlet weak var bottomButtonBottomConstraint: NSLayoutConstraint!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(detachedProfile: PearDetachedProfile) -> ApproveDetachedProfileSchoolViewController? {
    let storyboard = UIStoryboard(name: String(describing: ApproveDetachedProfileSchoolViewController.self), bundle: nil)
    guard let photoInputVC = storyboard.instantiateInitialViewController() as? ApproveDetachedProfileSchoolViewController else { return nil }
    photoInputVC.detachedProfile = detachedProfile
    return photoInputVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let profileApprovalVC = ApproveDetachedProfileViewController.instantiate(detachedProfile: self.detachedProfile) else {
      print("Failed to create Approve Detached Profile VC")
      return
    }
    self.navigationController?.pushViewController(profileApprovalVC, animated: true)
  }
  
  @IBAction func skipButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let profileApprovalVC = ApproveDetachedProfileViewController.instantiate(detachedProfile: self.detachedProfile) else {
      print("Failed to create Approve Detached Profile VC")
      return
    }
    self.navigationController?.pushViewController(profileApprovalVC, animated: true)
  }
  
}

// MARK: - Life Cycle
extension ApproveDetachedProfileSchoolViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    self.nextButton.stylizeDark()
    self.skipButton.stylizeSubtle()
    self.titleLabel.stylizeTitleLabel()
    
    self.progressWidthConstraint.constant = (pageNumber - 1.0) / StylingConfig.totalProfileApprovalPagesNumber * self.view.frame.width
    self.view.layoutIfNeeded()
    
    self.schoolNameContainer.stylizeInputTextFieldContainer()
    self.schoolYearContainer.stylizeInputTextFieldContainer()
    self.schoolNameTitle.stylizeTextFieldTitle()
    self.schoolYearTitle.stylizeTextFieldTitle()
    self.schoolNameTextField.stylizeInputTextField()
    self.schoolYearTextField.stylizeInputTextField()
    self.schoolNameTextField.delegate = self
    self.schoolYearTextField.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.view.layoutIfNeeded()
    self.progressWidthConstraint.constant = pageNumber / StylingConfig.totalProfileApprovalPagesNumber * self.view.frame.width
    UIView.animate(withDuration: StylingConfig.progressBarAnimationDuration, delay: StylingConfig.progressBarAnimationDelay, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
}

// MARK: - Text Field Delegate
extension ApproveDetachedProfileSchoolViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == self.schoolNameTextField {
      self.schoolYearTextField.becomeFirstResponder()
    } else if textField == self.schoolYearTextField {
      self.nextButtonClicked(self.nextButton as Any)
    }
    return false
  }
  
}

// MARK: - Keybaord Size Notifications
extension ApproveDetachedProfileSchoolViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(ApproveDetachedProfileSchoolViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(ApproveDetachedProfileSchoolViewController.keyboardWillHide(notification:)),
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
extension ApproveDetachedProfileSchoolViewController {
  
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ApproveDetachedProfileSchoolViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.schoolNameTextField.resignFirstResponder()
    self.schoolYearTextField.resignFirstResponder()
  }
  
}
