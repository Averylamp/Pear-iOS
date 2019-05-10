//
//  UILabel+Kerning.swift
//  Pear
//
//  Created by Avery Lamp on 3/1/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
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
  
  func calculateMaxLines() -> Int {
    let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
    let charSize = font.lineHeight
    let text = (self.text ?? "") as NSString
    let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil)
    let linesRoundedUp = Int(ceil(textSize.height/charSize))
    return linesRoundedUp
  }
  
}
