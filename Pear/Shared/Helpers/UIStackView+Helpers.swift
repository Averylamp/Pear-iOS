//
//  UIStackView+Helpers.swift
//  Pear
//
//  Created by Avery Lamp on 5/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
extension UIStackView {
  
  func addSpacer(height: CGFloat) {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = nil
    view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal,
                                          toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
    self.addArrangedSubview(view)
  }
  
}
