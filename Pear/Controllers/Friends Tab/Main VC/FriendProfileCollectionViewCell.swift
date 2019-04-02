//
//  FriendProfileCollectionViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 4/2/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SDWebImage

class FriendProfileCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var cardView: UIView!
  @IBOutlet weak var firstImageView: UIImageView!
  @IBOutlet weak var pendingApprovalLabel: UILabel!
  @IBOutlet weak var pendingApprovalBackground: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  
  func configureForProfileType(profileData: FullProfileDisplayData) {
    self.cardView.layer.cornerRadius = 8
    self.cardView.layer.shadowOpacity = 0.2
    self.cardView.layer.shadowColor = UIColor.black.cgColor
    self.cardView.layer.shadowRadius = 4
    self.cardView.layer.shadowOffset = CGSize(width: 1, height: 1)
    self.firstImageView.clipsToBounds = true
    self.firstImageView.contentMode = .scaleAspectFill
    self.firstImageView.layer.cornerRadius = 8
    
    if profileData.profileOrigin == .detachedProfile {
      self.firstImageView.alpha = 0.5
      self.nameLabel.alpha = 0.5
      self.pendingApprovalLabel.isHidden = false
      self.pendingApprovalBackground.isHidden = false
    } else {
      self.firstImageView.alpha = 1.0
      self.nameLabel.alpha = 1.0
      self.pendingApprovalLabel.isHidden = true
      self.pendingApprovalBackground.isHidden = true
      self.pendingApprovalBackground.layer.cornerRadius = self.pendingApprovalBackground.frame.height / 2.0
    }
    if let firstImage = profileData.rawImages.first {
      self.firstImageView.image = firstImage
      self.nameLabel.isHidden = true
    } else if let firstImageURLString = profileData.imageContainers.first?.medium.imageURL,
      let firstImageURL = URL(string: firstImageURLString) {
      self.firstImageView.sd_setImage(with: firstImageURL, completed: nil)
      self.nameLabel.isHidden = true
    } else {
      self.firstImageView.image = R.image.friendsNoImage()
      self.nameLabel.isHidden = false
      self.nameLabel.text = profileData.firstName
    }
  }
  
}
