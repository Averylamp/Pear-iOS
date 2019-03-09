//
//  UIButton+Styling.swift
//  Pear
//
//  Created by Avery Lamp on 3/1/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
  
  func stylizeDark() {
    self.backgroundColor = Colors.brandPrimaryLight
    self.layer.shadowColor = Colors.shadowColor.cgColor
    self.layer.shadowOpacity = 1
    self.layer.shadowRadius = 1
    self.layer.shadowOffset = CGSize(width: 0, height: 1)
    self.layer.cornerRadius = self.frame.height / 2.0
    self.layer.borderWidth = 2
    self.layer.borderColor = Colors.brandPrimaryDark.cgColor
    
    self.setTitleColor(UIColor.white, for: .normal)
    self.titleLabel?.font = UIFont(name: StylingConfig.textFontExtraBold, size: 17)
  }
  
  func stylizeFacebookColor() {
    self.backgroundColor = UIColor(red: 0.21, green: 0.35, blue: 0.62, alpha: 1.00)
    self.layer.cornerRadius = self.frame.height / 2.0
    self.setTitleColor(UIColor.white, for: .normal)
    self.titleLabel?.font = UIFont(name: StylingConfig.textFontSemiBold, size: 17)
  }
  
  func stylizeLight() {
    self.backgroundColor = UIColor.white
    self.layer.cornerRadius = self.frame.height / 2.0
    
    self.layer.shadowColor = UIColor(white: 0.0, alpha: 0.25).cgColor
    self.layer.shadowOffset = CGSize(width: 1, height: 1)
    self.layer.shadowOpacity = 1.0
    self.setTitleColor(StylingConfig.textFontColor, for: .normal)
    self.setTitleColor(Colors.brandPrimaryDark, for: .normal)
    self.titleLabel?.font = UIFont(name: StylingConfig.textFontSemiBold, size: 17)
  }
  
  func stylizeAllowFeature() {
    self.backgroundColor = UIColor.white
    self.layer.cornerRadius = self.frame.height / 2.0
    self.layer.borderColor = StylingConfig.textFontColor.cgColor
    self.setTitleColor(StylingConfig.textFontColor, for: .normal)
    self.titleLabel?.font = UIFont(name: StylingConfig.textFontSemiBold, size: 17)
  }
  
  func stylizeSubtle() {
    self.backgroundColor = nil
    self.setTitleColor(UIColor(red: 0.77, green: 0.78, blue: 0.79, alpha: 1.00), for: .normal)
    self.layer.borderWidth = 0
    self.titleLabel?.font = UIFont(name: StylingConfig.textFontRegular, size: 17)
  }
  
}
