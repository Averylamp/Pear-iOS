//
//  LatestRoastBoastTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 4/19/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class LatestRoastBoastTableViewCell: UITableViewCell {
  
  @IBOutlet weak var roastBoastImage: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var timestampLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func configure(item: LatestRoastBoastItem) {
    if item.type == .roast {
      self.titleLabel.text = "\(item.creatorFirstName) roasted \(item.userFirstName)"
      self.roastBoastImage.image = R.image.iconRoast()
    } else {
      self.titleLabel.text = "\(item.creatorFirstName) boasted \(item.userFirstName)"
      self.roastBoastImage.image = R.image.iconBoast()
    }
    
    self.timestampLabel.text = item.timestamp.timeAgoSinceDate()
    self.contentLabel.text = item.contentText
    
  }
  
}
