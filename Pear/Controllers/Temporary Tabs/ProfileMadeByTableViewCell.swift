//
//  ProfileMadeByTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 3/15/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfileMadeByTableViewCell: UITableViewCell {

  @IBOutlet weak var statusLabel: UILabel?
  @IBOutlet weak var subtextLabel: UILabel!
  @IBOutlet weak var profileFirstImageView: UIImageView!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
