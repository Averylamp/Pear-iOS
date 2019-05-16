//
//  UIImageView+Styling.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

// MARK: - Onboarding
extension UIImageView {
  func stylizeOnboardingMemeImage() {
    self.layer.shadowOpacity = 1.0
    self.layer.shadowRadius = 4.0
    self.layer.shadowOffset = CGSize(width: 0, height: 4)
    self.layer.shadowColor = UIColor(white: 0.0, alpha: 0.05).cgColor
  }
}
