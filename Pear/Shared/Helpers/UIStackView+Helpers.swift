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
  
  func addTitleLabel(text: String, insets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    if let font = R.font.openSansBold(size: 16) {
      titleLabel.font = font
    }
    titleLabel.textColor =  UIColor(white: 0.6, alpha: 1.0)
    titleLabel.text = text
    containerView.addSubview(titleLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: insets.left),
      NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -insets.right),
      NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: insets.top),
      NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -insets.bottom)
      ])
    self.addArrangedSubview(containerView)
  }
  
  func addInformationLabel(text: String, insets: UIEdgeInsets) {
    let containerView = UIView()
    let infoLabel = UILabel()
    infoLabel.translatesAutoresizingMaskIntoConstraints = false
    if let font = R.font.openSansSemiBold(size: 14.0) {
      infoLabel.font = font
    }
    infoLabel.text = text
    infoLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
    containerView.addSubview(infoLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: infoLabel, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: insets.left),
      NSLayoutConstraint(item: infoLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -insets.right),
      NSLayoutConstraint(item: infoLabel, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: insets.top),
      NSLayoutConstraint(item: infoLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -insets.bottom)
      ])
    self.addArrangedSubview(containerView)
  }
  
}
