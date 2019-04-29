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
  
  var boastTVC = MultipleBoastRoastStackViewController.instantiate(type: .boast)!
  var roastTVC = MultipleBoastRoastStackViewController.instantiate(type: .roast)!
  
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
      self.scrollView.scrollRectToVisible(self.boastTVC.view.frame, animated: true)
      Analytics.logEvent("CP_rb_TAP_boastTab", parameters: nil)
    } else if sender.tag == 3 {
      self.mode = .roast
      self.scrollView.scrollRectToVisible(self.roastTVC.view.frame, animated: true)
      Analytics.logEvent("CP_rb_TAP_roastTab", parameters: nil)
    }
    self.stylizeBoastRoastButtons()
  }
  
  @IBAction func addMoreButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.addBoastRoastVC(type: self.mode == .boast ? .boast : .roast)
    if self.mode == .boast {
      Analytics.logEvent("CP_rb_TAP_addBoast", parameters: nil)
    } else if self.mode == .roast {
      Analytics.logEvent("CP_rb_TAP_addRoast", parameters: nil)
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
    if let boasts = self.boastTVC.getBoastRoastItems() as? [BoastItem] {
      print("Boasts:\(boasts)")
      self.profileData.boasts = boasts
    }
    if let roasts = self.roastTVC.getBoastRoastItems() as? [RoastItem] {
      print("Roasts:\(roasts)")
      self.profileData.roasts = roasts
    }
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    Analytics.logEvent("CP_rb_TAP_continue", parameters: nil)
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
    Analytics.logEvent("CP_rb_DONE", parameters: nil)
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
    self.view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.00)
    if let font = R.font.openSansExtraBold(size: 16) {
      self.titleLabel.font = font
    }
    self.titleLabel.textColor = UIColor(white: 0.0, alpha: 0.5)
    
    var size: CGFloat = 24
    if self.view.frame.width < 325 {
      size = 20
    }
    
    guard let font = R.font.openSansExtraBold(size: size) else {
      print("Failed to find font")
      return
    }
    guard let boastColor = R.color.boastColor(),
      let roastColor = R.color.roastColor() else {
        print("Failed to create roast or boast color")
        return
    }
    self.boastButton.setAttributedTitle(
      
      NSAttributedString(string: "BOAST 'EM",
                         attributes: [NSAttributedString.Key.font: font,
                                      NSAttributedString.Key.foregroundColor: boastColor.withAlphaComponent(0.3)]),
      for: .normal)
    
    self.boastButton.setAttributedTitle(
      NSAttributedString(string: "BOAST 'EM",
                         attributes: [NSAttributedString.Key.font: font,
                                      NSAttributedString.Key.foregroundColor: boastColor]),
      for: .selected)
    
    self.roastButton.setAttributedTitle(
      NSAttributedString(string: "ROAST 'EM",
                         attributes: [NSAttributedString.Key.font: font,
                                      NSAttributedString.Key.foregroundColor: roastColor.withAlphaComponent(0.3)]),
      for: .normal)
    
    self.roastButton.setAttributedTitle(
      NSAttributedString(string: "ROAST 'EM",
                         attributes: [NSAttributedString.Key.font: font,
                                      NSAttributedString.Key.foregroundColor: roastColor]),
      for: .selected)
    self.stylizeBoastRoastButtons()
    
    self.addMoreButton.layer.cornerRadius = self.addMoreButton.frame.height / 2.0
    self.addMoreButton.setTitleColor(UIColor.white, for: .normal)
    
    self.continueButton.layer.cornerRadius = self.continueButton.frame.height / 2.0
    self.continueButton.setTitleColor(UIColor.black, for: .normal)
    self.continueButton.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.00)
    
  }
  
  func setup() {
    self.scrollView.isPagingEnabled = true
    self.scrollView.delegate = self
    
    self.addChild(self.boastTVC)
    self.addChild(self.roastTVC)
    self.stackView.addArrangedSubview(self.boastTVC.view)
    self.stackView.addArrangedSubview(self.roastTVC.view)
    self.boastTVC.didMove(toParent: self)
    self.roastTVC.didMove(toParent: self)
    self.scrollView.addConstraints([
      NSLayoutConstraint(item: self.boastTVC.view as Any, attribute: .height, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .height, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.boastTVC.view as Any, attribute: .width, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.roastTVC.view as Any, attribute: .height, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .height, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.roastTVC.view as Any, attribute: .width, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0.0)
      ])
    
  }
  
  func stylizeBoastRoastButtons() {
    switch self.mode {
    case .boast:
      self.boastButton.isSelected = true
      self.roastButton.isSelected = false
      self.subtitleLabel.text = "A “pro” of dating them!\nHype 👏 them 👏 up 👏"
      self.addMoreButton.backgroundColor = R.color.boastColor()
      self.addMoreButton.setTitle("Add Boast", for: .normal)
    case .roast:
      self.boastButton.isSelected = false
      self.roastButton.isSelected = true
      self.subtitleLabel.text = "Something people should know;\nnobody’s perfect ;P"
      self.addMoreButton.backgroundColor = R.color.roastColor()
      self.addMoreButton.setTitle("Add Roast", for: .normal)
    }
  }
  
  func addBoastRoastVC(type: ExpandingBoastRoastInputType) {
    if type == .boast {
      self.boastTVC.addBoastRoastVC()
    } else if type == .roast {
      self.roastTVC.addBoastRoastVC()
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

// MARK: - UIScrollViewDelegate
extension ProfileInputBoastRoastViewController: UIScrollViewDelegate {
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.scrollViewDidEndScrolling()
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      self.scrollViewDidEndScrolling()
    }
  }
  
  func scrollViewDidEndScrolling() {
    let pageIndex: Int = Int(floor(scrollView.contentOffset.x / scrollView.frame.width))
    if pageIndex == 0 {
      self.mode = .boast
    } else if pageIndex == 1 {
      self.mode = .roast
    }
    self.stylizeBoastRoastButtons()
  }
}
