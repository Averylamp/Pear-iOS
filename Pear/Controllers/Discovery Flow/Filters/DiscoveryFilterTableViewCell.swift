//
//  DiscoveryFilterTableViewCell.swift
//  Pear
//
//  Created by Brian Gu on 4/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SDWebImage

class DiscoveryFilterTableViewCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var checkboxBackground: UIImageView!
  @IBOutlet weak var checkboxChecked: UIImageView!
  @IBOutlet weak var thumbnailImage: UIImageView!
  
  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

}

// MARK: - Cell Configuration
extension DiscoveryFilterTableViewCell {
  
  func configure(discoveryFilterItem: DiscoveryFilterItem) {
    self.thumbnailImage.clipsToBounds = true
    self.thumbnailImage.contentMode = .scaleAspectFill
    self.thumbnailImage.layer.cornerRadius = 24
    switch discoveryFilterItem.type {
    case .personalUser:
      if let user = discoveryFilterItem.user {
        self.nameLabel.text = user.firstName
        self.thumbnailImage.image = R.image.discoveryYouButton()
      }
    case .endorsedUser:
      if let endorsedUser = discoveryFilterItem.endorsedUser {
        self.nameLabel.text = endorsedUser.firstName
        if let firstImageURLString = endorsedUser.displayedImages.first?.thumbnail.imageURL,
          let firstImageURL = URL(string: firstImageURLString) {
          self.thumbnailImage.sd_setImage(with: firstImageURL, completed: nil)
        } else {
          self.thumbnailImage.image = R.image.friendsNoImage()
        }
      }
    case .detachedProfile:
      if let detachedProfile = discoveryFilterItem.detachedProfile {
        self.nameLabel.text = detachedProfile.firstName
        if let firstImageURLString = detachedProfile.images.first?.thumbnail.imageURL,
          let firstImageURL = URL(string: firstImageURLString) {
          self.thumbnailImage.sd_setImage(with: firstImageURL, completed: nil)
        } else {
          self.thumbnailImage.image = R.image.friendsNoImage()
        }
      }
    }
    checkboxChecked.isHidden = !discoveryFilterItem.checked
    self.nameLabel.stylizeFilterName(selected: discoveryFilterItem.checked)
  }
  
}
