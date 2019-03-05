//
//  UITextField+Styling.swift
//  Pear
//
//  Created by Avery Lamp on 2/28/19.
//  Copyright © 2019 sam. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    func stylizeInputTextField() {
        self.font = UIFont(name: StylingConfig.displayFontRegular, size: 18)
        self.textColor = StylingConfig.textFontColor
        self.tintColor = StylingConfig.textFontColor
    }
    
}
