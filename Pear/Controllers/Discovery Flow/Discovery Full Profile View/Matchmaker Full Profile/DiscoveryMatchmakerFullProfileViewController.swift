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
