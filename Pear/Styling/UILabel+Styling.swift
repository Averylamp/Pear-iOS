//
//  UILabelExtensions.swift
//  Pear
//
//  Created by Avery Lamp on 2/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

// MARK: - User Signup
extension UILabel {
  func stylizeUserSignupTitleLabel() {
    self.textColor = R.color.primaryTextColor()
    if let font = R.font.openSansBold(size: 16) {
      self.font = font
    }
  }
  
  func stylizeUserSignupSubtitleLabel() {
    self.textColor = R.color.primaryTextColor()
    if let font = R.font.openSansExtraBold(size: 20) {
      self.font = font
    }
  }
}

// MARK: - Onboarding
extension UILabel {
  
  func stylizeOnboardingMemeTitleLabel() {
    self.textColor = R.color.primaryTextColor()
    if let font = R.font.openSansBold(size: 20) {
      self.font = font
    }
  }
  
  func stylizeOnboardingHeaderTitleLabel() {
    self.textColor = R.color.primaryTextColor()
    if let font = R.font.openSansBold(size: 16) {
      self.font = font
    }
  }
  
}

// MARK: - General Use
extension UILabel {
  func stylizeGeneralHeaderTitleLabel() {
    self.textColor = R.color.primaryTextColor()
    if let font = R.font.openSansBold(size: 16) {
      self.font = font
    }
  }
}

extension UILabel {
  
  func stylizeTitleLabel() {
    self.font = UIFont(name: StylingConfig.displayFontRegular, size: 28)
    self.textColor = StylingConfig.textFontColor
  }
  
  func stylizeFullPageNameLabel() {
    if let font = R.font.openSansBold(size: 34) {
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
    if let font = R.font.openSansSemiBold(size: 15) {
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
    if let font = R.font.openSansSemiBold(size: 17) {
      self.font = font
    }
    self.textColor = UIColor.black
  }
  
  func stylizeRequestSubtitleLabel() {
    if let font = R.font.openSansRegular(size: 17) {
      self.font = font
    }
    self.textColor = UIColor.black
  }
  
  func stylizeEditTitleLabel() {
    if let font = R.font.openSansBold(size: 18) {
      self.font = font
    }
    self.textColor = R.color.primaryTextColor()
  }
  
  func stylizeEditSubtitleLabel() {
    if let font = R.font.openSansRegular(size: 15) {
      self.font = font
    }
    self.textColor = R.color.primaryTextColor()
  }
  
  func stylizeChatRequestNameLabel(unread: Bool) {
    if unread {
      if let font = R.font.openSansBold(size: 17) {
        self.font = font
      }
    } else {
      if let font = R.font.openSansRegular(size: 17) {
        self.font = font
      }
    }
    self.textColor = R.color.primaryTextColor()
  }

  func stylizeChatRequestPreviewTextLabel(unread: Bool) {
    if unread {
      self.textColor = R.color.primaryTextColor()
      if let font = R.font.openSansRegular(size: 16) {
        self.font = font
      }
    } else {
      self.textColor = R.color.secondaryTextColor()
      if let font = R.font.openSansRegular(size: 16) {
        self.font = font
      }
    }
  }
  
  func stylizeFilterName(enabled: Bool) {
    if let font = R.font.openSansSemiBold(size: 17) {
      self.font = font
    }
    if enabled {
      self.textColor = R.color.primaryTextColor()
    } else {
      self.textColor = R.color.tertiaryTextColor()
    }
  }
  
  func stylizeChatRequestDateLabel(unread: Bool) {
    if unread {
      self.textColor = R.color.chatAccentColor()
      if let font = R.font.openSansBold(size: 13) {
        self.font = font
      }
    } else {
      self.textColor = R.color.secondaryTextColor()
      if let font = R.font.openSansRegular(size: 13) {
        self.font = font
      }
    }
  }
  
  func stylizeFullChatNameHeader() {
    if let font = R.font.openSansExtraBold(size: 17) {
      self.font = font
    }
    self.textColor = R.color.primaryTextColor()
  }
  
  func stylizeChatMessageServerRequest() {
    if let font = R.font.openSansRegular(size: 13) {
      self.font = font
    }
    self.textColor = R.color.secondaryTextColor()
  }
  
  func sylizeMatchmakerRequestLabel() {
    if let font = R.font.openSansSemiBold(size: 17) {
      self.font = font
    }
    self.textColor = R.color.primaryTextColor()
  }
  
  func stylizeChatMessageText(sender: Bool) {
    if let font = R.font.openSansRegular(size: 16) {
      self.font = font
    }
    if sender {
      self.textColor = UIColor.white
    } else {
      self.textColor = R.color.primaryTextColor()
    }
  }
  
  func stylizeChatMessageTimestamp(sender: Bool) {
    if let font = R.font.openSansRegular(size: 13) {
      self.font = font
    }
    if sender {
      self.textColor = UIColor(white: 1.0, alpha: 0.8)
    } else {
      self.textColor = R.color.secondaryTextColor()?.withAlphaComponent(0.8)
    }
  }
  
  func stylizeDiscoveryTagLabel() {
    if let font = R.font.openSansBold(size: 12) {
      self.font = font
    }
    self.textColor = UIColor.white
  }
  
}
