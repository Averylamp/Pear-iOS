//
//  UILabelExtensions.swift
//  Pear
//
//  Created by Avery Lamp on 2/25/19.
//  Copyright © 2019 sam. All rights reserved.
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
    
    func stylizeSubtitleLabel() {
        self.font = UIFont(name: StylingConfig.textFontSemiBold, size: 22)
        self.textColor = StylingConfig.textFontColor
    }
    
    func stylizeSubtitleLabelSmall() {
        self.font = UIFont(name: StylingConfig.textFontSemiBold, size: 17)
        self.textColor = StylingConfig.textFontColor
    }
    
    func stylizeTextFieldTitle() {
        self.font = UIFont(name: StylingConfig.displayFontRegular, size: 12)
        self.textColor = UIColor(red: 0.26, green: 0.29, blue: 0.33, alpha: 1.00)
    }
}
