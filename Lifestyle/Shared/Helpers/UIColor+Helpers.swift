//
//  Color+Helpers.swift
//  Pear
//
//  Created by Avery Lamp on 4/22/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  // swiftlint:disable:next large_tuple
  var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return (red, green, blue, alpha)
  }
  
  var hexColor: String {
    return String(format: "#%02x%02x%02x", Int(rgba.red * 255), Int(rgba.green * 255), Int(rgba.blue * 255))
  }
  
}
