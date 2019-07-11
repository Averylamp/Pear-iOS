//
//  DiscoveryMatchmakerFullProfileViewController.swift
//  Pear
//
//  Created by Avery Lamp on 7/7/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

class DiscoveryMatchmakerFullProfileViewController: DiscoveryFullProfileViewController {

  var fullPageBlocker: UIButton?
  var chatRequestVC: UIViewController?
  var chatRequestVCBottomConstraint: NSLayoutConstraint?
  let pearButton = UIButton()
  var matchmakingForID: String!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(fullProfileData: FullProfileDisplayData, matchmakingForID: String) -> DiscoveryMatchmakerFullProfileViewController? {
    guard let fullDiscoveryVC = R.storyboard.discoveryMatchmakerFullProfileViewController
      .instantiateInitialViewController() else { return nil }
    fullDiscoveryVC.fullProfileData = fullProfileData
    fullDiscoveryVC.matchmakingForID = matchmakingForID
    guard let matchingUserObject = fullProfileData.originObject as? PearUser else {
      print("Failed to get matching user object from full profile")
      return nil
    }
    fullDiscoveryVC.profileID = matchingUserObject.documentID
    return fullDiscoveryVC
  }
  
  @objc func pearButtonClicked(sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
  }
  
}

// MARK: - Life Cycle
extension DiscoveryMatchmakerFullProfileViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupMatchmakerVC()
    self.stylizeMatchmakerVC()
  }
  
  /// Setup should only be called once
  func setupMatchmakerVC() {
    self.view.addSubview(pearButton)
    self.pearButton.translatesAutoresizingMaskIntoConstraints = false
    self.pearButton.addTarget(self,
                              action: #selector(DiscoveryMatchmakerFullProfileViewController.pearButtonClicked(sender:)),
                              for: .touchUpInside)
    self.pearButton.contentMode = .scaleAspectFit
    self.pearButton.setImage(R.image.discoveryIconPear(), for: .normal)
    self.pearButton.setImage(R.image.discoveryIconPearSelected(), for: .selected)
    self.stylizeActionButton(button: self.pearButton)
    self.view.addConstraints([
      NSLayoutConstraint(item: self.pearButton, attribute: .centerY, relatedBy: .equal,
                         toItem: self.skipButton, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.pearButton, attribute: .width, relatedBy: .equal,
                         toItem: self.skipButton, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.pearButton, attribute: .height, relatedBy: .equal,
                         toItem: self.skipButton, attribute: .height, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.pearButton, attribute: .right, relatedBy: .equal,
                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: -15.0)
      ])
  }
  
  /// Stylize can be called more than once
  func stylizeMatchmakerVC() {
    
  }
  
}

// MARK: - Prompt Request VC
extension DiscoveryMatchmakerFullProfileViewController {

  

}

// MARK: - Keybaord Size Notifications
extension DiscoveryMatchmakerFullProfileViewController {

  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(DiscoveryMatchmakerFullProfileViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(DiscoveryMatchmakerFullProfileViewController.keyboardWillHide(notification:)),
                   name: UIWindow.keyboardWillHideNotification,
                   object: nil)
  }

  @objc func keyboardWillChange(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
      let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let targetFrame = targetFrameNSValue.cgRectValue
      if let requestBottomConstraint = self.chatRequestVCBottomConstraint {
        requestBottomConstraint.constant = -(targetFrame.height - self.view.safeAreaInsets.bottom + 20)
        print("Constraint Value: \(requestBottomConstraint.constant)")
      }
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  @objc func keyboardWillHide(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      if let requestBottomConstraint = self.chatRequestVCBottomConstraint {
        requestBottomConstraint.constant =  20
      }
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }

}


