//
//  InputItemTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 4/22/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class InputItemTableViewCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var checkboxImage: UIImageView!
  @IBOutlet weak var itemImageView: UIImageView!
  @IBOutlet weak var itemImageWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var checkboxImageWidthConstraint: NSLayoutConstraint!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.backgroundColor = nil
    self.selectionStyle = .none
    if let font = R.font.openSansExtraBold(size: 16) {
      self.titleLabel.font = font
    }
    if let font = R.font.openSansRegular(size: 16) {
      self.contentLabel.font = font
    }
    self.itemImageView.contentMode = .scaleAspectFit
    self.checkboxImage.contentMode = .scaleAspectFit
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    if selected {
      self.checkboxImage.image = R.image.iconCheckRound()
    } else {
      self.checkboxImage.image = nil
    }
    
  }
  
  func configure(inputItem: QuestionSuggestedResponse, selected: Bool) {
    checkboxImageWidthConstraint.constant = 30
    
    if selected {
      self.checkboxImage.image = R.image.iconCheckRound()
    } else {
      self.checkboxImage.image = nil
    }
    
    if let image = inputItem.icon?.cachedImage {
      self.itemImageWidthConstraint.constant = 35
      self.itemImageView.image = image
    } else if let icon =  inputItem.icon, icon.assetLikelyExists() {
      self.itemImageWidthConstraint.constant = 35
      self.itemImageView.image = nil
      icon.asyncUIImageFetch { (image) in
        DispatchQueue.main.async {
          if let image = image {
            self.itemImageView.image = image
          }
        }
      }
    } else {
      self.itemImageWidthConstraint.constant = 0
    }
    
    if let color = inputItem.color {
      self.titleLabel.textColor = color.uiColor()
      self.contentLabel.textColor = color.uiColor()
    }
    if let itemTitle = inputItem.responseTitle {
      self.titleLabel.isHidden = false
      self.titleLabel.text = itemTitle
    } else {
      self.titleLabel.isHidden = true
    }
    self.contentLabel.text = inputItem.responseBody
    
  }
}