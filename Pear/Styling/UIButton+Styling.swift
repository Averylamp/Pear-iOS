//
//  UIButton+Styling.swift
//  Pear
//
//  Created by Avery Lamp on 3/1/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Onboarding
extension UIButton {
  func stylizeOnboardingContinueButton() {
    self.backgroundColor = R.color.primaryBrandColor()
    self.setTitleColor(UIColor.white, for: .normal)
    if let font = R.font.openSansBold(size: 18) {
      self.titleLabel?.font = font
    }
    self.layer.cornerRadius = 12
  }
  
  func stylizeSaveToProfileButton() {
    self.backgroundColor = R.color.primaryBrandColor()
    self.setTitleColor(UIColor.white, for: .normal)
    if let font = R.font.openSansBold(size: 18) {
      self.titleLabel?.font = font
    }
    self.layer.cornerRadius = 12
  }
}

extension UIButton {
  
  func addButtonShadow() {
    self.layer.shadowOpacity = 1
    self.layer.shadowRadius = 1
    self.layer.shadowOffset = CGSize(width: 0, height: 1)
    self.layer.shadowColor = R.color.shadowColor()!.cgColor
  }
  
  func stylizeDark() {
    self.backgroundColor = R.color.primaryBrandColor()!
    self.layer.cornerRadius = 12.0
    self.layer.borderWidth = 2
    self.layer.borderColor = R.color.primaryBrandColor()!.cgColor
    self.setTitleColor(UIColor.white, for: .normal)
    if let font = R.font.openSansBold(size: 17) {
      self.titleLabel?.font = font
    }
  }
  
  func stylizeChatAccept() {
    self.backgroundColor = R.color.chatAccentColor()!
    self.layer.cornerRadius = self.frame.height / 2.0
    self.setTitleColor(UIColor.white, for: .normal)
    if let font = R.font.openSansBold(size: 18) {
      self.titleLabel?.font = font
    }
  }
  
  func stylizeChatDecline() {
    self.backgroundColor = UIColor.white
    self.layer.cornerRadius = self.frame.height / 2.0
    self.setTitleColor(R.color.chatDeclineColor(), for: .normal)
    if let font = R.font.openSansBold(size: 18) {
      self.titleLabel?.font = font
    }
  }
  
  func stylizeFacebookColor() {
    self.backgroundColor = R.color.facebookColor()
    self.layer.cornerRadius = self.frame.height / 2.0
    self.setTitleColor(UIColor.white, for: .normal)
    self.titleLabel?.font = UIFont(name: StylingConfig.textFontExtraBold, size: 17)
  }
  
  func stylizePreferencesOn() {
    self.backgroundColor = UIColor.white
    self.layer.cornerRadius = self.frame.height / 2.0
    self.setTitleColor(UIColor.black, for: .normal)
    if let font = R.font.openSansBold(size: 18) {
      self.titleLabel?.font = font
    }
  }
  
  func stylizePreferencesOff() {
    self.backgroundColor = UIColor.white.withAlphaComponent(0.3)
    self.layer.cornerRadius = self.frame.height / 2.0
    self.setTitleColor(UIColor.black, for: .normal)
    if let font = R.font.openSansBold(size: 18) {
      self.titleLabel?.font = font
    }
  }
  
  func stylizeLight() {
    self.backgroundColor = UIColor.white
    self.layer.cornerRadius = 12
    self.setTitleColor(R.color.primaryBrandColor()!, for: .normal)
    if let font = R.font.openSansBold(size: 18) {
      self.titleLabel?.font = font
    }
    self.layer.borderColor = R.color.primaryBrandColor()?.cgColor
    self.layer.borderWidth = 2
  }
  
  func stylizeDescructive() {
    self.backgroundColor = UIColor.white
    self.layer.cornerRadius = 12
    self.setTitleColor(UIColor.red, for: .normal)
    if let font = R.font.openSansBold(size: 18) {
      self.titleLabel?.font = font
    }
    self.layer.borderColor = UIColor.red.cgColor
    self.layer.borderWidth = 2
  }
  
  func stylizeLightSelected() {
    self.backgroundColor = UIColor.white
    self.layer.cornerRadius = self.frame.height / 2.0
    
    self.layer.shadowColor = UIColor(white: 0.0, alpha: 0.25).cgColor
    self.layer.shadowOffset = CGSize(width: 1, height: 1)
    self.layer.shadowOpacity = 1.0
    self.setTitleColor(StylingConfig.textFontColor, for: .normal)
    self.setTitleColor(R.color.primaryBrandColor()!, for: .normal)
    self.titleLabel?.font = UIFont(name: StylingConfig.textFontExtraBold, size: 17)
    
    self.layer.borderColor = R.color.primaryBrandColor()?.cgColor
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
    self.setTitleColor(StylingConfig.tertiaryTextFontColor, for: .normal)
    self.layer.borderWidth = 0
    if let font = R.font.openSansBold(size: 17) {
      self.titleLabel?.font = font
    }
  }
  
  func stylizeTextFieldButton() {
    if let font = R.font.openSansLight(size: 12) {
      self.titleLabel?.font = font
    }
    self.setTitleColor(R.color.primaryTextColor(), for: .normal)
  }
  
  func stylizeEditAddSection() {
    if let font = R.font.openSansBold(size: 17) {
      self.titleLabel?.font = font
    }
    self.setTitleColor(UIColor(red: 0.13, green: 0.59, blue: 0.95, alpha: 1.00), for: .normal)
  }
  
}
