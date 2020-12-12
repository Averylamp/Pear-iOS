//
//  UIView+Styling.swift
//  Pear
//
//  Created by Avery Lamp on 2/28/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

extension UIView {
  
  func stylizeInputTextFieldContainer() {
    self.layer.cornerRadius = 8
    self.layer.borderColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00).cgColor
    self.layer.borderWidth = 1
  }
}
