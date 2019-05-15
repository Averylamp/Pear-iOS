//
//  KeyboardEventsProtocol.swift
//  Pear
//
//  Created by Avery Lamp on 5/15/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardEventsBottomProtocol {
  var bottomKeyboardConstraint: NSLayoutConstraint? {get}
  var bottomKeyboardPadding: CGFloat {get}
  func addKeyboardNotifications(animated: Bool)
}

extension KeyboardEventsBottomProtocol where Self: UIViewController {
  func addKeyboardNotifications(animated: Bool) {
    NotificationCenter.default.addObserver(forName: UIWindow.keyboardWillChangeFrameNotification, object: nil, queue: nil) { (notification) in
      if let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
        let targetFrame = targetFrameNSValue.cgRectValue
        if let bottomKeyboardConstraint = self.bottomKeyboardConstraint {
          bottomKeyboardConstraint.constant = targetFrame.size.height - self.view.safeAreaInsets.bottom + self.bottomKeyboardPadding
        }
        if animated,
          let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
          UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
          }
        } else {
          self.view.layoutIfNeeded()
        }
      }
      NotificationCenter.default.addObserver(forName: UIWindow.keyboardWillHideNotification, object: nil, queue: nil, using: { (notification) in
        if let bottomKeyboardConstraint = self.bottomKeyboardConstraint {
          bottomKeyboardConstraint.constant = self.bottomKeyboardPadding
        }
        if animated,
          let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
          UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
          }
        } else {
          self.view.layoutIfNeeded()
        }
      })
    }
  }

}

protocol KeyboardEventsDismissTapProtocol {
  func addKeyboardDismissOnTap()
}

extension KeyboardEventsDismissTapProtocol where Self: UIViewController {
  
  func dismissKeyboard() {
    self.view.endEditing(true)
  }
}
