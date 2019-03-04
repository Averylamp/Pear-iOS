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
        self.font = UIFont(name: Config.displayFontRegular, size: 18)
        self.textColor = Config.textFontColor
        self.tintColor = Config.textFontColor
    }
    
}
