//
//  UITextView+Styling.swift
//  Pear
//
//  Created by Avery Lamp on 4/7/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
  
  func stylizeEditTextLabel() {
    if let font = R.font.nunitoRegular(size: 17) {
      self.font = font
    }
    self.textColor = R.color.primaryTextColor()
  }
  
  func stylizeChatInputPlaceholder() {
    if let font = R.font.nunitoRegular(size: 17) {
      self.font = font
    }
    self.tintColor = R.color.primaryTextColor()
    self.textColor = R.color.tertiaryTextColor()
  }
  
  func stylizeChatInputText() {
    if let font = R.font.nunitoRegular(size: 17) {
      self.font = font
    }
    self.tintColor = R.color.primaryTextColor()
    self.textColor = R.color.primaryTextColor()
  }
  
}
