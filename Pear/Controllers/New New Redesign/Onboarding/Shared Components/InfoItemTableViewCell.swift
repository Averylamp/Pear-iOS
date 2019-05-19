//
//  InfoItemTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 5/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class InfoItemTableViewCell: UITableViewCell {
  
  @IBOutlet weak var fieldNameLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var visibilityLabel: UILabel!
  @IBOutlet weak var infoImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func stylize(item: InfoTableViewItem) {
    self.fieldNameLabel.text = item.titleText
    self.subtitleLabel.text = item.subtitleText
    if item.filledOut {
      self.subtitleLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
    } else {
      self.subtitleLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
    }
    self.visibilityLabel.text = item.visibility ? "Visible" : "Hidden"
    
  }
  
}
