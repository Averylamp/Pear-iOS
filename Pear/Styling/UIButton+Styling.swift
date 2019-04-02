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
    self.backgroundColor = R.color.brandPrimaryLight()!
    self.layer.shadowColor = R.color.shadowColor()!.cgColor
    self.layer.shadowOpacity = 1
    self.layer.shadowRadius = 1
    self.layer.shadowOffset = CGSize(width: 0, height: 1)
    self.layer.cornerRadius = self.frame.height / 2.0
    self.layer.borderWidth = 2
    self.layer.borderColor = R.color.brandPrimaryDark()!.cgColor
    
    self.setTitleColor(UIColor.white, for: .normal)
    self.titleLabel?.font = UIFont(name: StylingConfig.textFontExtraBold, size: 17)
  }
  
  func stylizeFacebookColor() {
    self.backgroundColor = R.color.facebookColor()
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
    self.setTitleColor(R.color.brandPrimaryDark()!, for: .normal)
    self.titleLabel?.font = UIFont(name: StylingConfig.textFontSemiBold, size: 17)
    self.layer.borderWidth = 0
  }
  
  func stylizeLightSelected() {
    self.backgroundColor = UIColor.white
    self.layer.cornerRadius = self.frame.height / 2.0
    
    self.layer.shadowColor = UIColor(white: 0.0, alpha: 0.25).cgColor
    self.layer.shadowOffset = CGSize(width: 1, height: 1)
    self.layer.shadowOpacity = 1.0
    self.setTitleColor(StylingConfig.textFontColor, for: .normal)
    self.setTitleColor(R.color.brandPrimaryDark()!, for: .normal)
    self.titleLabel?.font = UIFont(name: StylingConfig.textFontSemiBold, size: 17)
    
    self.layer.borderColor = R.color.brandPrimaryLight()?.cgColor
    self.layer.borderWidth = 2
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
