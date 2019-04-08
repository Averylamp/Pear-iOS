//
//  GetStartedSchoolViewController.swift
//  Pear
//
//  Created by Brian Gu on 4/8/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import BSImagePicker
import Photos
import Firebase

class GetStartedSchoolViewController: UIViewController {
  
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
  var gettingStartedData: UserProfileCreationData!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedData: UserProfileCreationData) -> GetStartedSchoolViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedSchoolViewController.self), bundle: nil)
    guard let chooseSchoolVC = storyboard.instantiateInitialViewController() as? GetStartedSchoolViewController else { return nil }
    chooseSchoolVC.gettingStartedData = gettingStartedData
    return chooseSchoolVC
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    
    let school = self.schoolNameTextField.text == "" ? nil : self.schoolNameTextField.text!
    let schoolYear = self.schoolYearTextField.text == "" || self.schoolYearTextField.text?.count != 4 ? nil : self.schoolYearTextField.text!
    self.gettingStartedData.school = school
    self.gettingStartedData.schoolYear = schoolYear
    
    guard let interestsVC = GetStartedInterestsViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
      print("Failed to create Interests VC")
      return
    }
    Analytics.logEvent("finished_friend_school", parameters: nil)
    self.navigationController?.pushViewController(interestsVC, animated: true)
  }
  
  @IBAction func skipButtonClicked(_ sender: Any) {
    guard let interestsVC = GetStartedInterestsViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
      print("Failed to create Interests VC")
      return
    }
    self.navigationController?.pushViewController(interestsVC, animated: true)
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    let alertController = UIAlertController(title: "Stop Making a Profile?", message: "Are you sure you want to cancel", preferredStyle: .alert)
    let continueAction = UIAlertAction(title: "Keep Going", style: .default, handler: nil)
    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
      DispatchQueue.main.async {
        guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
          print("Failed to initialize Main VC")
          return
        }
        self.navigationController?.setViewControllers([mainVC], animated: true)
      }
    }
    alertController.addAction(continueAction)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    Analytics.logEvent("clicked_friend_school_back", parameters: nil)
    self.navigationController?.popViewController(animated: true)
  }
  
}

// MARK: - Life Cycle
extension GetStartedSchoolViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    
    self.addKeyboardSizeNotifications()
    self.addDismissKeyboardOnViewClick()
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
extension GetStartedSchoolViewController: UITextFieldDelegate {
  
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
extension GetStartedSchoolViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(GetStartedSchoolViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(GetStartedSchoolViewController.keyboardWillHide(notification:)),
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
extension GetStartedSchoolViewController {
  
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GetStartedSchoolViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.schoolNameTextField.resignFirstResponder()
    self.schoolYearTextField.resignFirstResponder()
  }
  
}
