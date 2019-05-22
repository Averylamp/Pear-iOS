//
//  DiscoveryTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 3/31/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SDWebImage
import CoreLocation

protocol DiscoveryTableViewCellDelegate: class {
  func fullProfileViewTriggered(profileData: FullProfileDisplayData)
}

class DiscoveryTableViewCell: UITableViewCell {
  
  weak var delegate: DiscoveryTableViewCellDelegate?
  
  let contentItemTag: Int = 1532
  let imageTag: Int = 528
  
  @IBOutlet weak var profileStackView: UIStackView!
  @IBOutlet weak var imageScrollView: UIScrollView!
  @IBOutlet weak var scrollViewContentView: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var extraInfoStackView: UIStackView!
  @IBOutlet weak var vibeImageView: UIImageView!
  @IBOutlet weak var vibeImageWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var scrollViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var imageNumberControl: UIPageControl!
  
  var profileData: FullProfileDisplayData?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.imageScrollView.subviews.filter({ $0.tag == self.imageTag}).forEach({$0.removeFromSuperview()})
    self.imageScrollView.isPagingEnabled = true
    self.imageScrollView.showsHorizontalScrollIndicator = false
    self.imageScrollView.delegate = self
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DiscoveryTableViewCell.scrollViewTapped))
    self.imageScrollView.addGestureRecognizer(tapGestureRecognizer)
  }
  
  @IBAction func moreButtonClicked(_ sender: UIButton) {
    
  }
  
  override func layoutIfNeeded() {
    super.layoutIfNeeded()
    let imageCount = self.imageScrollView.subviews.filter({ $0.tag == self.imageTag}).count
    self.scrollViewWidthConstraint.constant = self.imageScrollView.frame.width * CGFloat(imageCount - 1)
  }
  
}

// MARK: - Cell Configuration
extension DiscoveryTableViewCell {
  func configureCell(profileData: FullProfileDisplayData) {
    self.profileData = profileData
    if let firstName = profileData.firstName {
      if let age = profileData.age {
        self.nameLabel.text = "\(firstName), \(age)"
      } else {
        self.nameLabel.text = "\(firstName)"
      }
    } else {
      self.nameLabel.text = "Name Hidden"
    }
    
    self.nameLabel.textColor = profileData.vibes.first?.color?.uiColor() != nil ? profileData.vibes.first?.color?.uiColor() : UIColor.black
    
    if let vibe = profileData.vibes.first {
      self.vibeImageWidthConstraint.constant = 45
      if let image = vibe.icon?.syncUIImageFetch() {
        self.vibeImageView.image = image
      } else if let assetURL = vibe.icon?.assetURL {
        self.vibeImageView.sd_setImage(with: assetURL, completed: nil)
      } else {
        self.vibeImageWidthConstraint.constant = 0
        self.vibeImageView.image = nil
      }
    } else {
      self.vibeImageWidthConstraint.constant = 0
      self.vibeImageView.image = nil
    }
    
    self.extraInfoStackView.subviews.forEach({
      self.extraInfoStackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    })
    
    if let locationName = profileData.locationName {
      self.extraInfoStackView.addArrangedSubview(self.generateInfoTagItem(name: locationName, icon: R.image.iconLocationMarker()))
    }
    if let schoolName = profileData.school {
      if let schoolYear = profileData.schoolYear {
        self.extraInfoStackView.addArrangedSubview(self.generateInfoTagItem(name: "\(schoolName), \(schoolYear)", icon: R.image.iconSchool()))
      } else {
        self.extraInfoStackView.addArrangedSubview(self.generateInfoTagItem(name: schoolName, icon: R.image.iconSchool()))
      }
    }
    self.populateImages(images: profileData.imageContainers)
    
    self.profileStackView.subviews.filter({$0.tag == self.contentItemTag}).forEach({
      self.profileStackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    })

    if let boastItem = profileData.boasts.first {
      self.addBoastRoastItem(item: boastItem, userName: profileData.firstName)
      self.addSpacerView(height: 4)
    }
    if let roastItem = profileData.roasts.first {
      self.addBoastRoastItem(item: roastItem, userName: profileData.firstName)
      self.addSpacerView(height: 4)
    }
    if profileData.boasts.count + profileData.roasts.count == 0,
      let bioItem = profileData.bios.first {
      self.addBioItem(item: bioItem)
    }
    self.updatePageControl()
  }
  
  func populateImages(images: [ImageContainer]) {
    self.imageNumberControl.numberOfPages = images.count
    self.imageNumberControl.currentPage = 0
    print("Populating \(images.count) images")
    self.imageScrollView.subviews.filter({ $0.tag == self.imageTag}).forEach({$0.removeFromSuperview()})
    self.layoutIfNeeded()
    for index in 0..<images.count {
      let image = images[index]
      let imageView = UIImageView()
      imageView.tag = self.imageTag
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.contentMode = .scaleAspectFill
      imageView.clipsToBounds = true
      if let imageURL = URL(string: image.medium.imageURL) {
        imageView.sd_setImage(with: imageURL, completed: nil)
      } else {
        imageView.image = nil
      }
      self.imageScrollView.addSubview(imageView)
      self.imageScrollView.addConstraints([
        NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal,
                           toItem: self.imageScrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal,
                           toItem: self.imageScrollView, attribute: .height, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal,
                           toItem: self.imageScrollView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal,
                           toItem: self.imageScrollView, attribute: .centerX, multiplier: (1.0 + (2 * CGFloat(index))), constant: 0.0)
        
        ])
      
    }
    self.scrollViewWidthConstraint.constant = self.imageScrollView.frame.width * CGFloat(images.count)
    
  }
  
  func generateInfoTagItem(name: String, icon: UIImage?) -> UIView {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    let tagLabel = UILabel()
    tagLabel.translatesAutoresizingMaskIntoConstraints = false
    if let font = R.font.openSansBold(size: 12) {
      tagLabel.font = font
    }
    tagLabel.textColor = UIColor(white: 0.2, alpha: 0.5)
    tagLabel.text = name
    containerView.addSubview(tagLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: tagLabel, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: tagLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: tagLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -8)
      ])
    
    if let icon = icon {
      let imageView = UIImageView()
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.contentMode = .scaleAspectFit
      imageView.image = icon
      imageView.alpha = 0.5
      containerView.addSubview(imageView)
      imageView.addConstraints([
        NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25),
        NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal,
                           toItem: imageView, attribute: .height, multiplier: 1.0, constant: 0)
        ])
      containerView.addConstraints([
        NSLayoutConstraint(item: tagLabel, attribute: .left, relatedBy: .equal,
                           toItem: imageView, attribute: .right, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal,
                           toItem: containerView, attribute: .left, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal,
                           toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
    } else {
      containerView.addConstraints([
        NSLayoutConstraint(item: tagLabel, attribute: .left, relatedBy: .equal,
                           toItem: containerView, attribute: .left, multiplier: 1.0, constant: 0.0)
        ])
      
    }
    return containerView
  }
  
  func addBoastRoastItem(item: BoastRoastItem, userName: String?) {
    guard let boastRoastVC = ProfileBoastRoastViewController.instantiate(boastRoastItem: item, userName: userName,
                                                                         style: .discovery, maxLines: 3) else {
      print("Failed to create Boast Roast Item")
      return
    }
    boastRoastVC.view.tag = self.contentItemTag
    self.profileStackView.addArrangedSubview(boastRoastVC.view)
  }
  
  func addBioItem(item: BioItem) {
    guard let bioItemVC = ProfileBioViewController.instantiate(bioItem: item, maxLines: 4) else {
      print("Failed to create Bio Item VC")
      return
    }
    bioItemVC.view.tag = self.contentItemTag
    self.profileStackView.addArrangedSubview(bioItemVC.view)
  }
  
  func addSpacerView(height: CGFloat) {
    let spacer = UIView()
    spacer.translatesAutoresizingMaskIntoConstraints = false
    spacer.backgroundColor = nil
    spacer.addConstraint(NSLayoutConstraint(item: spacer, attribute: .height, relatedBy: .equal,
                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
    self.profileStackView.addArrangedSubview(spacer)
  }
  
}

// MARK: - UIScrollViewDelegate
extension DiscoveryTableViewCell: UIScrollViewDelegate {
  
  func updatePageControl() {
    let pageIndex = round(self.imageScrollView.contentOffset.x / self.imageScrollView.frame.width)
    if Int(pageIndex) < self.imageNumberControl.numberOfPages {
      self.imageNumberControl.currentPage = Int(pageIndex)
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.updatePageControl()
  }
  
}

extension DiscoveryTableViewCell {
  @objc func scrollViewTapped() {
    if let delegate = delegate,
      let profileData = self.profileData {
      delegate.fullProfileViewTriggered(profileData: profileData)
    }
  }
}
