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

    @IBInspectable var kerning: Float {
        get {
            var range = NSRange(location: 0, length: (text ?? "").count)
            guard let kern = attributedText?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: &range),
                let value = kern as? NSNumber
                else {
                    return 0
            }
            return value.floatValue
        }
        set {
            var attText: NSMutableAttributedString

            if let attributedText = attributedText {
                attText = NSMutableAttributedString(attributedString: attributedText)
            } else if let text = text {
                attText = NSMutableAttributedString(string: text)
            } else {
                attText = NSMutableAttributedString(string: "")
            }

            let range = NSRange(location: 0, length: attText.length)
            attText.addAttribute(NSAttributedString.Key.kern, value: NSNumber(value: newValue), range: range)
            self.attributedText = attText
        }
    }

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
}
