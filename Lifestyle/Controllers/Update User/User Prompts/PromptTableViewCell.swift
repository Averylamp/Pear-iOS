//
//  PromptTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 5/29/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class PromptTableViewCell: UITableViewCell {
  
  @IBOutlet weak var cardView: UIView!
  
  @IBOutlet weak var thumbnailImage: UIImageView!
  @IBOutlet weak var creatorNameLabel: UILabel!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var responseLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.cardView.translatesAutoresizingMaskIntoConstraints = false
    self.cardView.layer.cornerRadius = 12
    self.cardView.layer.borderWidth = 1.0
    self.cardView.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    self.thumbnailImage.contentMode = .scaleAspectFill
    self.thumbnailImage.layer.cornerRadius = self.thumbnailImage.frame.height / 2.0
    self.thumbnailImage.clipsToBounds = true
    if let font = R.font.openSansBold(size: 12) {
      self.creatorNameLabel.font = font
    }
    self.creatorNameLabel.textColor = R.color.primaryTextColor()
    self.questionLabel.numberOfLines = 0
    if let font = R.font.openSansBold(size: 14) {
      self.questionLabel.font = font
    }
    self.questionLabel.textColor = R.color.primaryTextColor()
    self.responseLabel.numberOfLines = 0
    
    if let font = R.font.openSansSemiBold(size: 14) {
      self.responseLabel.font = font
    }
    self.responseLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
    self.selectionStyle = .none
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func stylize(prompt: QuestionResponseItem) {
    self.questionLabel.text = prompt.question.questionText
    self.creatorNameLabel.text = prompt.authorFirstName
    self.responseLabel.text = prompt.responseBody

    if let thumbnailImageString = prompt.authorThumbnailURL,
      let thumbnailURL = URL(string: thumbnailImageString) {
      self.thumbnailImage.sd_setImage(with: thumbnailURL, completed: nil)
    } else {
      self.thumbnailImage.image = R.image.discoveryPlacholderUserImage()
    }
    
    if prompt.hidden == false {
      self.cardView.alpha = 0.3
    } else {
      self.cardView.alpha = 1.0
    }
    
  }
  
}
