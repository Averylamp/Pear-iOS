//
//  DiscoveryFilterItemTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 7/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class DiscoveryFilterItemTableViewCell: UITableViewCell {

  let thumbnailImageView = UIImageView()
  let nameLabel = UILabel()
  let selectedImageView = UIImageView()
  static let sideOffsets: CGFloat = 12
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.contentView.addSubview(self.thumbnailImageView)
    self.thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.addSubview(self.nameLabel)
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.addSubview(self.selectedImageView)
    self.selectedImageView.translatesAutoresizingMaskIntoConstraints = false
    
    // Thumbnail Image Constraints
    self.contentView.addConstraints([
      NSLayoutConstraint(item: self.thumbnailImageView, attribute: .left, relatedBy: .equal,
                         toItem: self.contentView, attribute: .left, multiplier: 1.0, constant: DiscoveryFilterItemTableViewCell.sideOffsets),
      NSLayoutConstraint(item: self.thumbnailImageView, attribute: .centerY, relatedBy: .equal,
                         toItem: self.contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.thumbnailImageView, attribute: .height, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: DiscoveryFilterOverlayViewController.filterItemHeight - 16.0),
      NSLayoutConstraint(item: self.thumbnailImageView, attribute: .height, relatedBy: .equal,
                         toItem: self.thumbnailImageView, attribute: .width, multiplier: 1.0, constant: 0.0)
      ])
    
    // Label Constraints
    self.contentView.addConstraints([
      NSLayoutConstraint(item: self.nameLabel, attribute: .left, relatedBy: .equal,
                         toItem: self.thumbnailImageView, attribute: .right, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: self.nameLabel, attribute: .centerY, relatedBy: .equal,
                         toItem: self.thumbnailImageView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
      ])
    
    // Selected Image Constraints
    self.contentView.addConstraints([
      NSLayoutConstraint(item: self.selectedImageView, attribute: .right, relatedBy: .equal,
                         toItem: self.contentView, attribute: .right, multiplier: 1.0, constant: -DiscoveryFilterItemTableViewCell.sideOffsets),
      NSLayoutConstraint(item: self.selectedImageView, attribute: .centerY, relatedBy: .equal,
                         toItem: self.thumbnailImageView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.selectedImageView, attribute: .height, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 26.0),
      NSLayoutConstraint(item: self.selectedImageView, attribute: .height, relatedBy: .equal,
                         toItem: self.selectedImageView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.nameLabel, attribute: .right, relatedBy: .equal,
                         toItem: self.selectedImageView, attribute: .left, multiplier: 1.0, constant: -8.0)
      ])
    
    // Separator
    let seperatorView = UIView()
    seperatorView.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.addSubview(seperatorView)
    self.contentView.addConstraints([
      NSLayoutConstraint(item: seperatorView, attribute: .centerX, relatedBy: .equal,
                         toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: seperatorView, attribute: .width, relatedBy: .equal,
                         toItem: self.contentView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: seperatorView, attribute: .height, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0),
      NSLayoutConstraint(item: seperatorView, attribute: .bottom, relatedBy: .equal,
                         toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
      ])
    seperatorView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
    
    // Stylizes Thumbnail
    self.thumbnailImageView.contentMode = .scaleAspectFill
    self.thumbnailImageView.layer.cornerRadius = self.thumbnailImageView.frame.height / 2.0
    self.thumbnailImageView.clipsToBounds = true
    
    // Stylizes Label
    if let font = R.font.openSansBold(size: 18.0) {
      self.nameLabel.font = font
    }
    
    // Stylizes Selected Image
    self.selectedImageView.contentMode = .scaleAspectFit
    self.selectedImageView.image = R.image.discoveryFilterIconSelected()
    self.selectedImageView.alpha = 0.0
    
    self.layoutIfNeeded()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    if animated {
      UIView.animate(withDuration: 0.1) {
        self.selectedImageView.alpha = selected ? 1.0 : 0.0
      }
    } else {
      self.selectedImageView.alpha = selected ? 1.0 : 0.0
    }
  }
  
  func stylize(url: URL, firstName: String, selected: Bool) {
    self.thumbnailImageView.image = nil
    self.thumbnailImageView.layer.cornerRadius = self.thumbnailImageView.frame.height / 2.0
    self.thumbnailImageView.sd_setImage(with: url, completed: nil)
    self.nameLabel.text = firstName
  }
  
}
