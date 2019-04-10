//
//  DiscoveryFilterTableViewCell.swift
//  Pear
//
//  Created by Brian Gu on 4/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class DiscoveryFilterTableViewCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var checkbox: UILabel!
  
  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

}

// MARK: - Cell Configuration
extension DiscoveryFilterTableViewCell {
  
  func configure(discoveryFilterItem: DiscoveryFilterItem) {
    print("configuring for discoveryFilterItem:")
    switch discoveryFilterItem.type {
    case .personalUser:
      if let user = discoveryFilterItem.user {
        self.nameLabel.text = user.firstName
      }
    case .endorsedUser:
      if let endorsedUser = discoveryFilterItem.endorsedUser {
        self.nameLabel.text = endorsedUser.firstName
      }
    case .detachedProfile:
      if let detachedProfile = discoveryFilterItem.detachedProfile {
        self.nameLabel.text = detachedProfile.firstName
      }
    }
    self.checkbox.text = discoveryFilterItem.checked.description
  }
  
}
