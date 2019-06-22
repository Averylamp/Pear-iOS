//
//  FullChatViewController+Keyboard.swift
//  Pear
//
//  Created by Avery Lamp on 6/20/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAnalytics

// MARK: - Keybaord Size Notifications
extension FullChatViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(FullChatViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(FullChatViewController.keyboardWillHide(notification:)),
                   name: UIWindow.keyboardWillHideNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(FullChatViewController.keyboardDidHide(notification:)),
                   name: UIWindow.keyboardDidHideNotification,
                   object: nil)
  }
  
  @objc func keyboardWillChange(notification: Notification) {
    DispatchQueue.main.async {
      if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
        let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
        !self.keyboardIsHiding {
        let targetFrame = targetFrameNSValue.cgRectValue
        self.inputContainerViewBottomConstraint.constant = targetFrame.height - self.view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration) {
          self.view.layoutIfNeeded()
        }
        if !self.keyboardIsHiding {
          let scrollDistance = self.inputContainerViewBottomConstraint.constant - self.lastKeyboardHeight
          self.lastKeyboardHeight = self.inputContainerViewBottomConstraint.constant
          UIView.animate(withDuration: duration, animations: {
            self.tableView.contentOffset.y += scrollDistance
          })
        }
      }
    }
  }
  
  @objc func keyboardWillHide(notification: Notification) {
    self.keyboardIsHiding = true
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      self.inputContainerViewBottomConstraint.constant = 0
      self.lastKeyboardHeight = self.inputContainerViewBottomConstraint.constant
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
  @objc func keyboardDidHide(notification: Notification) {
    self.keyboardIsHiding = false
  }
  
}

// MARK: - Dismiss First Responder on Click
extension FullChatViewController {
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FullChatViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    Analytics.logEvent("CHAT_thread_EV_dismissKeyboard", parameters: nil)
    self.view.endEditing(true)
  }
}
