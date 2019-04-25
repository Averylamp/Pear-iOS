//
//  ProfileInputBoastRoastViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class ProfileInputBoastRoastViewController: UIViewController {
  
  @IBOutlet weak var boastButton: UIButton!
  @IBOutlet weak var roastButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var doneButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var addMoreButton: UIButton!
  @IBOutlet weak var continueButton: UIButton!
  
  enum BoastRoastMode {
    case boast
    case roast
  }
  
  var mode: BoastRoastMode = .boast
  var profileData: ProfileCreationData!
  var textVCs: [ExpandingBoastRoastInputViewController] = []
  
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
      Analytics.logEvent("CP_r&b_TAP_boastTab", parameters: nil)
    } else if sender.tag == 3 {
      self.mode = .roast
      Analytics.logEvent("CP_r&b_TAP_roastTab", parameters: nil)
    }
    self.stylizeBoastRoastButtons()
  }
  
  @IBAction func addMoreButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.addBoastRoastVC(type: self.mode == .boast ? .boast : .roast)
    if self.mode == .boast {
      Analytics.logEvent("CP_r&b_TAP_addBoast", parameters: nil)
    } else if self.mode == .roast {
      Analytics.logEvent("CP_r&b_TAP_addRoast", parameters: nil)
    }
  }
  @IBAction func cancelButtonClicked(_ sender: Any) {
    let alertController = UIAlertController(title: "Delete profile?", message: "Your progress will not be saved", preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
      DispatchQueue.main.async {
        guard let createProfileVC = LoadingScreenViewController.getProfileCreationVC() else {
          print("Failure instantiating  create profile VC")
          return
        }
        self.navigationController?.setViewControllers([createProfileVC], animated: true)
      }
    }
    alertController.addAction(alertAction)
    alertController.addAction(deleteAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  func saveBoastRoasts() {
    if let boasts = self.textVCs.filter({ $0.type == .boast}).compactMap({ $0.getBoastRoastItem()}) as? [BoastItem] {
      print("Boasts:\(boasts)")
      self.profileData.boasts = boasts
    }
    if let roasts = self.textVCs.filter({ $0.type == .roast}).compactMap({ $0.getBoastRoastItem()}) as? [RoastItem] {
      print("Roasts:\(roasts)")
      self.profileData.roasts = roasts
    }
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    Analytics.logEvent("CP_r&b_TAP_continue", parameters: nil)
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.saveBoastRoasts()
    if self.profileData.boasts.count + self.profileData.roasts.count == 0 {
      let alertController = UIAlertController(title: "You must write at least one", message: nil, preferredStyle: .alert)
      let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
      alertController.addAction(okayAction)
      self.present(alertController, animated: true, completion: nil)
      return
    }
    guard let firstNameVC = UserNameInputViewController.instantiate(profileCreationData: self.profileData) else {
      print("Couldnt create first name VC")
      return
    }
    self.navigationController?.pushViewController(firstNameVC, animated: true)
    Analytics.logEvent("CP_r&b_DONE", parameters: nil)

  }
  
}

// MARK: - Life Cycle
extension ProfileInputBoastRoastViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
    self.addDismissKeyboardOnViewClick()
    self.addKeyboardSizeNotifications()
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
      for: .normal)
    
    self.boastButton.setAttributedTitle(
      NSAttributedString(string: "Boast them",
                         attributes: [NSAttributedString.Key.font: font,
                                      NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 1.0) ]),
      for: .selected)
    
    self.roastButton.setAttributedTitle(
      NSAttributedString(string: "roast them",
                         attributes: [NSAttributedString.Key.font: font,
                                      NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                      NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.5) ]),
      for: .normal)
    
    self.roastButton.setAttributedTitle(
      NSAttributedString(string: "roast them",
                         attributes: [NSAttributedString.Key.font: font,
                                      NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 1.0) ]),
      for: .selected)
    self.stylizeBoastRoastButtons()
    
    self.addMoreButton.layer.cornerRadius = self.addMoreButton.frame.height / 2.0
    self.addMoreButton.setTitleColor(UIColor.black, for: .normal)
    self.addMoreButton.backgroundColor = R.color.backgroundColorYellow()
    
    self.continueButton.layer.cornerRadius = self.continueButton.frame.height / 2.0
    self.continueButton.setTitleColor(UIColor.white, for: .normal)
    self.continueButton.backgroundColor = UIColor(red: 0.56, green: 0.84, blue: 1.00, alpha: 1.00)
    
  }
  
  func setup() {
   self.addBoastRoastVC(type: .boast)
  }
  
  func stylizeBoastRoastButtons() {
    switch self.mode {
    case .boast:
      self.boastButton.isSelected = true
      self.roastButton.isSelected = false
      self.subtitleLabel.text = "A “pro” of dating them!\nHype 👏 them 👏 up 👏"
      if let lastTextVC = self.textVCs.last {
        lastTextVC.populatePlaceholder(type: .boast)
      }
    case .roast:
      self.boastButton.isSelected = false
      self.roastButton.isSelected = true
      self.subtitleLabel.text = "Something people should know;\nnobody’s perfect ;P"
      if let lastTextVC = self.textVCs.last {
        lastTextVC.populatePlaceholder(type: .roast)
      }
    }
  }
  
  func addBoastRoastVC(type: ExpandingBoastRoastInputType) {
    guard let expandingTextVC = ExpandingBoastRoastInputViewController.instantiate(type: type) else {
                    print("Failed to create expanding b/roast text vc")
                    return
    }
    
    expandingTextVC.delegate = self
    self.textVCs.append(expandingTextVC)
    self.addChild(expandingTextVC)
    self.stackView.addArrangedSubview(expandingTextVC.view)
    expandingTextVC.didMove(toParent: self)
    self.view.layoutIfNeeded()
    expandingTextVC.expandingTextView.becomeFirstResponder()
    self.scrollView.scrollRectToVisible(expandingTextVC.view.frame, animated: true)

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
      self.doneButtonBottomConstraint.constant = targetFrame.height - self.view.safeAreaInsets.bottom - self.continueButton.frame.height - 4
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  @objc func keyboardWillHide(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      self.doneButtonBottomConstraint.constant = 10.0
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
}

// MARK: - ExpandingBoastRoastInputViewDelegate
extension ProfileInputBoastRoastViewController: ExpandingBoastRoastInputViewDelegate {
  func returnPressed(controller: ExpandingBoastRoastInputViewController) {
    DispatchQueue.main.async {
      self.addBoastRoastVC(type: self.mode == .boast ? .boast : .roast)
    }
  }
  
  func deleteButtonPressed(controller: ExpandingBoastRoastInputViewController) {
    guard self.textVCs.count > 1 else {
      print("Cant remove last remaining item")
      controller.expandingTextView.text = ""
      return
    }
    guard self.stackView.arrangedSubviews.firstIndex(where: { $0 == controller.view }) != nil,
      let arrayIndex = self.textVCs.firstIndex(of: controller) else {
        print("Unable to find indices to remove")
        return
    }
    
    self.stackView.removeArrangedSubview(controller.view)
    controller.view.removeFromSuperview()
    self.textVCs.remove(at: arrayIndex)
  }
  
}
