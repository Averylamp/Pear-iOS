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
    self.cardView.backgroundColor = UIColor(red: 1.00, green: 0.93, blue: 0.88, alpha: 1.00)
    self.cardView.layer.cornerRadius = 12.0
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
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func stylize(prompt: QuestionResponseItem) {
    
  }
  
}
