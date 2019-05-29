//
//  EventFilterTableViewCell.swift
//  Pear
//
//  Created by Brian Gu on 5/28/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SDWebImage

class EventFilterTableViewCell: UITableViewCell {
  
  @IBOutlet weak var checkboxBackground: UIImageView!
  @IBOutlet weak var checkboxChecked: UIImageView!
  @IBOutlet weak var thumbnailImage: UIImageView!
  @IBOutlet weak var eventNameLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
}

// MARK: - Cell Configuration
extension EventFilterTableViewCell {
  
  func configure(eventFilterItem: EventFilterItem) {
    self.eventNameLabel.text = eventFilterItem.event.name
    checkboxChecked.isHidden = !eventFilterItem.checked
    self.eventNameLabel.stylizeFilterName(enabled: eventFilterItem.checked)
  }
  
}
