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
    self.font = UIFont(name: StylingConfig.textFontRegular, size: 17)
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
    self.font = UIFont(name: StylingConfig.textFontExtraBold, size: 17)
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
  
  func stylizeEditTitleLabel() {
    if let font = R.font.nunitoBold(size: 18) {
      self.font = font
    }
    self.textColor = R.color.primaryTextColor()
  }
  
  func stylizeEditSubtitleLabel() {
    if let font = R.font.nunitoRegular(size: 15) {
      self.font = font
    }
    self.textColor = R.color.primaryTextColor()
  }
  
  func stylizeChatRequestNameLabel(unread: Bool) {
    if unread {
      if let font = R.font.nunitoBold(size: 18) {
        self.font = font
      }
    } else {
      if let font = R.font.nunitoRegular(size: 17) {
        self.font = font
      }
    }
    self.textColor = R.color.primaryTextColor()
  }

  func stylizeChatRequestPreviewTextLabel(unread: Bool) {
    if unread {
      self.textColor = R.color.primaryTextColor()
      if let font = R.font.nunitoSemiBold(size: 16) {
        self.font = font
      }
    } else {
      self.textColor = R.color.secondaryTextColor()
      if let font = R.font.nunitoRegular(size: 16) {
        self.font = font
      }
    }
  }
  
  func stylizeFilterName(selected: Bool) {
    if let font = R.font.nunitoSemiBold(size: 17) {
      self.font = font
    }
    if selected {
      self.textColor = R.color.primaryTextColor()
    } else {
      self.textColor = R.color.tertiaryTextColor()
    }
  }
  
  func stylizeChatRequestDateLabel(unread: Bool) {
    if let font = R.font.nunitoRegular(size: 13) {
      self.font = font
    }
    if unread {
     self.textColor = R.color.brandPrimaryDark()
    } else {
      self.textColor = R.color.secondaryTextColor()
    }
  }
  
  func stylizeChatMessageServerRequest() {
    if let font = R.font.nunitoRegular(size: 13) {
      self.font = font
    }
    self.textColor = R.color.secondaryTextColor()
  }
  
  func stylizeChatMessageText(sender: Bool) {
    if let font = R.font.nunitoSemiBold(size: 17) {
      self.font = font
    }
    if sender {
      self.textColor = UIColor.white
    } else {
      self.textColor = R.color.primaryTextColor()
    }
  }
  
  func stylizeChatMessageTimestamp(sender: Bool) {
    if let font = R.font.nunitoRegular(size: 13) {
      self.font = font
    }
    if sender {
      self.textColor = UIColor(white: 1.0, alpha: 0.8)
    } else {
      self.textColor = R.color.secondaryTextColor()?.withAlphaComponent(0.8)
    }
  }
  
}
