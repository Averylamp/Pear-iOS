//
//  ContactListItemTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 4/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Contacts

class ContactListItemTableViewCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var pearImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    if let font = R.font.openSansExtraBold(size: 16) {
      self.nameLabel.font = font
    }
    if let font = R.font.openSansExtraBold(size: 12) {
      self.subtitleLabel.font = font
    }
    self.backgroundColor = nil
    self.contentView.backgroundColor = nil
    self.nameLabel.textColor = UIColor(white: 0.0, alpha: 1.0)
    self.subtitleLabel.textColor = UIColor(white: 0.0, alpha: 0.3)
    self.pearImageView.contentMode = .scaleAspectFit
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func configure(contactItem: ContactListItem) {
    if contactItem.enabled {
      self.nameLabel.textColor = UIColor(white: 0.0, alpha: 1.0)
      self.subtitleLabel.text = String.formatPhoneNumber(phoneNumber: contactItem.phoneNumber)
      self.pearImageView.image = R.image.iconPearEnabled()
    } else {
      self.subtitleLabel.text = "ALREADY PEARED"
      self.nameLabel.textColor = UIColor(white: 0.0, alpha: 0.3)
      self.pearImageView.image = R.image.iconPearDisabled()
    }
    self.nameLabel.text = contactItem.name
  }
  
}
