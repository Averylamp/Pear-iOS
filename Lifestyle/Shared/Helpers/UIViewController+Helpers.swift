//
//  UIViewControllerExtensions.swift
//  Pear
//
//  Created by Avery Lamp on 2/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  
  func delay(delay: Double, closure: @escaping() -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
  }
  
}
