//
//  UILabelExtensions.swift
//  Pear
//
//  Created by Avery Lamp on 2/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
  
  func stylizeLogoLabel() {
    self.font = UIFont(name: StylingConfig.logoFont, size: 32)
    self.kerning = 3.0
  }
  
  func stylizeTitleLabel() {
    self.font = UIFont(name: StylingConfig.displayFontRegular, size: 28)
    self.textColor = StylingConfig.textFontColor
  }
  
  func stylizeFullPageNameLabel() {
    if let font = R.font.nunitoBold(size: 34) {
     self.font = font
    }
    self.textColor = StylingConfig.textFontColor
  }
  
  func stylizeSubtitleLabel() {
    self.font = UIFont(name: StylingConfig.textFontSemiBold, size: 22)
    self.textColor = StylingConfig.textFontColor
  }
  func stylizeTagLabel() {
    self.font = UIFont(name: StylingConfig.textFontBold, size: 20)
    self.textColor = StylingConfig.textFontColor
  }
  
  func stylizeSubtitleLabelSmall() {
    self.font = UIFont(name: StylingConfig.textFontSemiBold, size: 17)
    self.textColor = StylingConfig.textFontColor
  }
  
  func stylizeTextFieldTitle() {
    self.font = UIFont(name: StylingConfig.displayFontRegular, size: 12)
    self.textColor = StylingConfig.textFontColor
  }
  
  func stylizeBioLabel() {
    self.font = UIFont(name: StylingConfig.textFontSemiBold, size: 22)
    self.textColor = StylingConfig.textFontColor
  }
  func stylizeCreatorLabel(preText: String, boldText: String) {
    let preText = NSMutableAttributedString(string: preText, attributes: [NSAttributedString.Key.font: UIFont(name: StylingConfig.textFontRegular, size: 16) as Any])
    let boldText = NSAttributedString(string: boldText, attributes: [NSAttributedString.Key.font: UIFont(name: StylingConfig.textFontBold, size: 16) as Any])
    preText.append(boldText)
    self.attributedText = preText
    self.textColor = StylingConfig.textFontColor
  }
  
  func stylizeDoDontLabel() {
    self.font = UIFont(name: StylingConfig.textFontSemiBold, size: 22)
    self.textColor = StylingConfig.textFontColor
  }
  
  func stylizeTagViewLabel() {
    self.font = UIFont(name: StylingConfig.textFontExtraBold, size: 17)
    self.textColor = StylingConfig.textFontColor
  }
  
  func stylizeProfileSectionTitleLabel() {
    self.font = UIFont(name: StylingConfig.textFontExtraBold, size: 17)
    self.textColor = StylingConfig.textFontColor
  }
  
  func stylizeInfoSubtextLabel() {
    if let font = R.font.nunitoSemiBold(size: 15) {
      self.font = font
    }
    self.minimumScaleFactor = 0.5
    self.adjustsFontSizeToFitWidth = true
    self.textColor = StylingConfig.textFontColor
  }
  
  func stylizePreferencesTitleLabel() {
    self.font = UIFont(name: StylingConfig.textFontSemiBold, size: 17)
    self.textColor = StylingConfig.textFontColor
  }
  
  func stylizePreferencesSubtitleLabel() {
    self.font = UIFont(name: StylingConfig.displayFontRegular, size: 15)
    self.textColor = StylingConfig.textFontColor
  }
  
  func stylizeRequestTitleLabel() {
    if let font = R.font.nunitoSemiBold(size: 17) {
      self.font = font
    }
    self.textColor = UIColor.black
  }
  
  func stylizeRequestSubtitleLabel() {
    if let font = R.font.nunitoRegular(size: 17) {
      self.font = font
    }
    self.textColor = UIColor.black
  }
}
