//
//  AddEventTableViewCell.swift
//  Pear
//
//  Created by Brian Gu on 5/28/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class AddEventTableViewCell: UITableViewCell {
  
  @IBOutlet weak var addEventButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.stylize()
  }
  
  func stylize() {
    self.addEventButton.stylizeLight()
  }
  
}
