//
//  UITextField+Styling.swift
//  Pear
//
//  Created by Avery Lamp on 2/28/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
  
  func stylizeInputTextField() {
    self.font = UIFont(name: StylingConfig.displayFontRegular, size: 18)
    self.textColor = StylingConfig.textFontColor
    self.tintColor = StylingConfig.textFontColor
  }
  
  func stylizeUpdateInputTextField() {
    if let font = R.font.nunitoRegular(size: 18) {
      self.font = font
    }
    self.textColor = R.color.primaryTextColor()
    self.tintColor = R.color.primaryTextColor()
  }
  
}
