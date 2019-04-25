//
//  DiscoveryTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 3/31/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SDWebImage

protocol DiscoveryTableViewCellDelegate: class {
  func fullProfileViewTriggered(profileData: FullProfileDisplayData)
  func receivedVerticalPanTranslation(yTranslation: CGFloat)
  func endedVerticalPanTranslation(yVelocity: CGFloat)
}

class DiscoveryTableViewCell: UITableViewCell {
  
  weak var delegate: DiscoveryTableViewCellDelegate?
  
  var profileData: FullProfileDisplayData!
  var imageViews: [UIImageView] = []
  var indicatorViews: [UIView] = []

  @IBOutlet weak var imageScrollView: UIScrollView!
  @IBOutlet weak var scrollViewContentView: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var extraInfoStackView: UIStackView!
  @IBOutlet weak var vibeImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  @IBAction func moreButtonClicked(_ sender: UIButton) {
    
  }
  
}

// MARK: - Cell Configuration
extension DiscoveryTableViewCell {
  func configureCell(profileData: FullProfileDisplayData) {
    
    print(profileData)
    
  }
  
}

// MARK: - UIScrollViewDelegate
extension DiscoveryTableViewCell: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
    
  }
  
}

extension DiscoveryTableViewCell {

}
