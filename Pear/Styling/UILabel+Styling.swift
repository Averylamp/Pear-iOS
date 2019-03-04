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
        self.font = UIFont(name: Config.logoFont, size: 32)
        self.kerning = 3.0
    }
    
    func stylizeTitleLabel() {
        self.font = UIFont(name: Config.displayFontRegular, size: 28)
        self.textColor = Config.textFontColor
    }
    
    func stylizeSubtitleLabel() {
        self.font = UIFont(name: Config.textFontSemiBold, size: 22)
        self.textColor = Config.textFontColor
    }
    
    func stylizeSubtitleLabelSmall() {
        self.font = UIFont(name: Config.textFontSemiBold, size: 17)
        self.textColor = Config.textFontColor
    }
    
    func stylizeTextFieldTitle() {
        self.font = UIFont(name: Config.displayFontRegular, size: 12)
        self.textColor = UIColor(red: 0.26, green: 0.29, blue: 0.33, alpha: 1.00)
    }
}
