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
                         toItem: self.contentView, attribute: .height, multiplier: 1.0, constant: -20.0),
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
                         toItem: self.contentView, attribute: .height, multiplier: 1.0, constant: -20),
      NSLayoutConstraint(item: self.selectedImageView, attribute: .height, relatedBy: .equal,
                         toItem: self.selectedImageView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.nameLabel, attribute: .right, relatedBy: .equal,
                         toItem: self.selectedImageView, attribute: .left, multiplier: 1.0, constant: -8.0)
      ])
    
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
    self.selectedImageView.backgroundColor = UIColor.green
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func stylize(url: URL, firstName: String, selected: Bool) {
    self.thumbnailImageView.image = nil
    self.thumbnailImageView.layer.cornerRadius = self.thumbnailImageView.frame.height / 2.0
    self.thumbnailImageView.sd_setImage(with: url, completed: nil)
    self.nameLabel.text = firstName
    self.selectedImageView.alpha = selected ? 1.0 : 0.0
  }
  
}
