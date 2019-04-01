//
//  GetStartedShortBioViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class GetStartedShortBioViewController: UIViewController {
  
  var gettingStartedData: UserProfileCreationData!
  
  @IBOutlet weak var textLengthLabel: UILabel!
  @IBOutlet weak var inputTextView: UITextView!
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
  
  let keyboardBottomPadding: CGFloat = 40
  let maxTextLength: Int = 600
  let pageNumber: CGFloat = 6.0
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedData: UserProfileCreationData) -> GetStartedShortBioViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedShortBioViewController.self), bundle: nil)
    guard let shortBioVC = storyboard.instantiateInitialViewController() as? GetStartedShortBioViewController else { return nil }
    shortBioVC.gettingStartedData = gettingStartedData
    return shortBioVC
  }
  
  func saveBio() {
    self.gettingStartedData.bio = inputTextView.text
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
    self.saveBio()
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.saveBio()
    if let profileBio = self.gettingStartedData.bio {
      if profileBio.count < 50 {
        let alertController = UIAlertController(title: nil,
                                                message: "Your bio seems a little short 🤔.  Don't you think your friend deserves a little more?",
                                                preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Yeah, I'll help 'em out", style: .cancel, handler: nil)
        let continueButton = UIAlertAction(title: "Continue anyway", style: .default) { (_) in
          if self.gettingStartedData.bio?.count == 0 {
            self.gettingStartedData.bio = " "
          }
          DispatchQueue.main.async {
            guard let photoInputVC = GetStartedPhotoInputViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
              print("Failed to create photoInputVC")
              return
            }
            self.navigationController?.pushViewController(photoInputVC, animated: true)
          }
        }
        
        alertController.addAction(cancelButton)
        alertController.addAction(continueButton)
        self.present(alertController, animated: true, completion: nil)
      } else {
        guard let photoInputVC = GetStartedPhotoInputViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
          print("Failed to create photoInputVC")
          return
        }
        self.navigationController?.pushViewController(photoInputVC, animated: true)
      }
    }
  }
  
  @IBAction func sampleButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let sampleBiosVC = GetStartedSampleBiosViewController.instantiate() else {
      print("Failed to create Sample Bios VC")
      return
    }
    self.present(sampleBiosVC, animated: true, completion: nil)
  }
  
}

// MARK: - Life Cycle
extension GetStartedShortBioViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.inputTextView.delegate = self
    self.inputTextView.isScrollEnabled = true
    
    if let profileBio = self.gettingStartedData.bio, profileBio != "" {
      self.inputTextView.text = profileBio
      textViewDidChange(self.inputTextView)
    }
    
    self.updateTextLabels()
    self.addDismissKeyboardOnViewClick()
    self.addKeyboardSizeNotifications()
    self.stylize()
  }
  
  func stylize() {
    self.nextButton.stylizeDark()
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabelSmall()
    
    self.inputTextView.layer.borderColor = StylingConfig.textFontColor.cgColor
    self.inputTextView.layer.borderWidth = 1
    self.inputTextView.layer.cornerRadius = 15
    self.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    self.inputTextView.font = UIFont(name: StylingConfig.displayFontRegular, size: 17)
    self.inputTextView.textColor = StylingConfig.textFontColor
    
    self.progressWidthConstraint.constant = (pageNumber - 1) / StylingConfig.totalGettingStartedPagesNumber * self.view.frame.width
    self.view.layoutIfNeeded()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.view.layoutIfNeeded()
    self.progressWidthConstraint.constant = pageNumber / StylingConfig.totalGettingStartedPagesNumber * self.view.frame.width
    UIView.animate(withDuration: StylingConfig.progressBarAnimationDuration, delay: StylingConfig.progressBarAnimationDelay, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
}

// MARK: - Dismiss First Responder on Click
extension GetStartedShortBioViewController {
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GetStartedShortBioViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.inputTextView.resignFirstResponder()
  }
}

// MARK: - UITextView Delegate
extension GetStartedShortBioViewController: UITextViewDelegate {
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if textView.text.count + text.count - range.length > maxTextLength {
      return false
    }
    return true
  }
  
  func updateTextLabels() {
    if self.inputTextView.text.count > 500 {
      self.textLengthLabel.text = "\(self.inputTextView.text.count) / \(maxTextLength)"
      self.textLengthLabel.isHidden = false
    } else {
      self.textLengthLabel.isHidden = true
    }
  }
  
  func textViewDidChange(_ textView: UITextView) {
    self.updateTextLabels()
  }
  
}

// MARK: - Keybaord Size Notifications
extension GetStartedShortBioViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(GetStartedShortBioViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(GetStartedShortBioViewController.keyboardWillHide(notification:)),
                   name: UIWindow.keyboardWillHideNotification,
                   object: nil)
  }
  
  @objc func keyboardWillChange(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
      let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let targetFrame = targetFrameNSValue.cgRectValue
      self.nextButtonBottomConstraint.constant = targetFrame.height - self.view.safeAreaInsets.bottom + keyboardBottomPadding
      if self.view.frame.height < 600 && targetFrame.height > 0 {
        self.nextButtonBottomConstraint.constant = targetFrame.height - self.view.safeAreaInsets.bottom - self.nextButton.frame.height
      }
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  @objc func keyboardWillHide(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      self.nextButtonBottomConstraint.constant = self.keyboardBottomPadding
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
}
