//
//  DiscoveryTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 3/31/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SDWebImage

class DiscoveryTableViewCell: UITableViewCell {
  
  var profileData: FullProfileDisplayData!
  var imageViews: [UIImageView] = []
  var bioView: BioView!
  var doView: DoDontView!
  var dontView: DoDontView!
  
  @IBOutlet weak var contentScrollView: UIScrollView!
  @IBOutlet weak var contentStackView: UIStackView!
  @IBOutlet weak var itemsStackView: UIStackView!
  
  let indentWidth: CGFloat = 20.0
  
  override func awakeFromNib() {
    super.awakeFromNib()
    print("Awake from nib called")
    self.setupContentViews()
    self.setupScrollView()
  }
  
  func setupContentViews() {
    for _ in 0..<3 {
      imageViews.append(self.getImageView())
    }
    self.bioView = self.getBioView(bioText: "", creatorName: "")
    self.doView = self.getDoDont(contentText: "", creatorName: "", type: .doType)
    self.dontView = self.getDoDont(contentText: "", creatorName: "", type: .dontType)
    let allViews: [UIView] = [
      self.imageViews[0],
      self.bioView,
      self.imageViews[1],
      self.doView,
      self.imageViews[2],
      self.dontView
    ]
    
    for view in allViews {
      self.contentStackView.addArrangedSubview(view)
      self.contentScrollView.addConstraints([
        NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal,
                           toItem: self.contentScrollView, attribute: .width, multiplier: 1.0, constant: 0)
        ])
    }
    
  }
  
  func setupScrollView() {
    self.contentScrollView.delegate = self
    self.contentScrollView.isPagingEnabled = true
  }
  
  func configureCell(profileData: FullProfileDisplayData) {
    self.profileData = profileData
    for index in 0..<3 {
      let imageView = self.imageViews[index]
      imageView.image = nil
      if index < profileData.rawImages.count {
        print("Raw Image")
        imageView.image = profileData.rawImages[index]
        imageView.isHidden = false
      } else if index < profileData.imageContainers.count,
        let imageURL = URL(string: profileData.imageContainers[index].medium.imageURL) {
        print("ImageURL")
        imageView.sd_setImage(with: imageURL, completed: nil)
        imageView.isHidden = false
      } else {
        print("Hiding image: \(index)")
        imageView.isHidden = true
      }
    }
    if let bioContent = profileData.bio.first {
      self.bioView.isHidden = false
      self.bioView.writtenByLabel?.stylizeCreatorLabel(preText: "Written by ", boldText: bioContent.creatorName)
      self.bioView.contentLabel?.text = bioContent.bio
    } else {
      self.bioView.isHidden = true
    }
    if let doContent = profileData.dos.first {
      self.doView.isHidden = false
      self.doView.writtenByLabel?.stylizeCreatorLabel(preText: "Written by ", boldText: doContent.creatorName)
      self.doView.contentLabel?.text = doContent.phrase
    } else {
      self.doView.isHidden = true
    }
    if let dontContent = profileData.donts.first {
      self.dontView.isHidden = false
      self.dontView.writtenByLabel?.stylizeCreatorLabel(preText: "Written by ", boldText: dontContent.creatorName)
      self.dontView.contentLabel?.text = dontContent.phrase
    } else {
      self.dontView.isHidden = true
    }
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}

extension DiscoveryTableViewCell: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
  }
  
}

extension DiscoveryTableViewCell {
  func getImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    
    return imageView
  }
  
  func getBioView(bioText: String, creatorName: String) -> BioView {
    let containerView = BioView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    let contentTextLabel = UILabel()
    contentTextLabel.numberOfLines = 0
    contentTextLabel.text = bioText
    contentTextLabel.stylizeDoDontLabel()
    contentTextLabel.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(contentTextLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: contentTextLabel, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: indentWidth),
      NSLayoutConstraint(item: contentTextLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -indentWidth),
      NSLayoutConstraint(item: contentTextLabel, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0.0)
      ])
    
    let writtenByLabel = UILabel()
    writtenByLabel.stylizeCreatorLabel(preText: "Written by ", boldText: creatorName)
    writtenByLabel.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(writtenByLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: writtenByLabel, attribute: .top, relatedBy: .equal,
                         toItem: contentTextLabel, attribute: .bottom, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: writtenByLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -16.0)
      
      ])
    
    let writtenByImage = UIImageView()
    writtenByImage.contentMode = .scaleAspectFit
    writtenByImage.image = UIImage(named: "profile-icon-creator-leaf")
    writtenByImage.translatesAutoresizingMaskIntoConstraints = false
    writtenByImage.addConstraints([
      NSLayoutConstraint(item: writtenByImage, attribute: .width, relatedBy: .equal,
                         toItem: writtenByImage, attribute: .height, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: writtenByImage, attribute: .width, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30)
      ])
    containerView.addSubview(writtenByImage)
    containerView.addConstraints([
      NSLayoutConstraint(item: writtenByImage, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: indentWidth),
      NSLayoutConstraint(item: writtenByImage, attribute: .right, relatedBy: .equal,
                         toItem: writtenByLabel, attribute: .left, multiplier: 1.0, constant: -16),
      NSLayoutConstraint(item: writtenByImage, attribute: .centerY, relatedBy: .equal,
                         toItem: writtenByLabel, attribute: .centerY, multiplier: 1.0, constant: 0.0)
      ])
    
    containerView.writtenByLabel = writtenByLabel
    containerView.contentLabel = contentTextLabel
    
    return containerView
  }
  
  func getDoDont(contentText: String, creatorName: String, type: DoDontType) -> DoDontView {
    let containerView = DoDontView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    var fullContentText = ""
    switch type {
    case .doType:
      fullContentText += "\"Do " + contentText + "\""
    case .dontType:
      fullContentText += "\"Don't " + contentText + "\""
    }
    
    let contentTextLabel = UILabel()
    contentTextLabel.numberOfLines = 0
    contentTextLabel.text = fullContentText
    contentTextLabel.stylizeDoDontLabel()
    contentTextLabel.translatesAutoresizingMaskIntoConstraints = false
    contentTextLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    containerView.addSubview(contentTextLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: contentTextLabel, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: indentWidth),
      NSLayoutConstraint(item: contentTextLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -indentWidth),
      NSLayoutConstraint(item: contentTextLabel, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0.0)
      ])
    
    let writtenByLabel = UILabel()
    writtenByLabel.stylizeCreatorLabel(preText: "Written by ", boldText: creatorName)
    writtenByLabel.translatesAutoresizingMaskIntoConstraints = false
    writtenByLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    containerView.addSubview(writtenByLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: writtenByLabel, attribute: .top, relatedBy: .equal,
                         toItem: contentTextLabel, attribute: .bottom, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: writtenByLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -16.0)
      
      ])
    
    let writtenByImage = UIImageView()
    writtenByImage.contentMode = .scaleAspectFit
    writtenByImage.image = UIImage(named: "profile-icon-creator-leaf")
    writtenByImage.translatesAutoresizingMaskIntoConstraints = false
    writtenByImage.addConstraints([
      NSLayoutConstraint(item: writtenByImage, attribute: .width, relatedBy: .equal,
                         toItem: writtenByImage, attribute: .height, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: writtenByImage, attribute: .width, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30)
      ])
    containerView.addSubview(writtenByImage)
    containerView.addConstraints([
      NSLayoutConstraint(item: writtenByImage, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: indentWidth),
      NSLayoutConstraint(item: writtenByImage, attribute: .right, relatedBy: .equal,
                         toItem: writtenByLabel, attribute: .left, multiplier: 1.0, constant: -16),
      NSLayoutConstraint(item: writtenByImage, attribute: .centerY, relatedBy: .equal,
                         toItem: writtenByLabel, attribute: .centerY, multiplier: 1.0, constant: 0.0)
      ])
    
    containerView.writtenByLabel = writtenByLabel
    containerView.contentLabel = contentTextLabel
    
    return containerView
  }
}
