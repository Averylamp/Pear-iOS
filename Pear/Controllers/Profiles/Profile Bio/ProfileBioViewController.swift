//
//  ProfileBioViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

struct BioContent {
  let bio: String
  let creatorName: String
}

class ProfileBioViewController: UIViewController {
  
  @IBOutlet var scrollView: UIScrollView!
  var bioContent: [BioContent] = []
  var intrinsicContentHeights: [CGFloat] = []
  @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(bioContent: [BioContent]) -> ProfileBioViewController? {
    let storyboard = UIStoryboard(name: String(describing: ProfileBioViewController.self), bundle: nil)
    guard let bioVC = storyboard.instantiateInitialViewController() as? ProfileBioViewController else { return nil }
    bioVC.bioContent = bioContent
    return bioVC
  }
  
}

// MARK: - Life Cycle
extension ProfileBioViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Removes placeholder content view to stop sizing
    self.scrollView.subviews.forEach({$0.removeFromSuperview()})
    self.stylize()
    self.addBioContent()
    self.scrollView.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.view.layoutIfNeeded()
    
    self.scrollView.contentSize = CGSize(width: self.view.frame.width * CGFloat(self.intrinsicContentHeights.count),
                                         height: 0)
    print(self.scrollView.contentSize)
    self.scrollViewDidScroll(self.scrollView)
    self.delay(delay: 5) {
      print(self.scrollView.contentSize)
    }
  }
  
  func stylize() {
    self.scrollView.isPagingEnabled = true
    self.scrollView.showsHorizontalScrollIndicator = true
    self.scrollView.showsVerticalScrollIndicator = false
  }
  
  func addBioContent() {
    var itemNumber: CGFloat = 0
    for contentItem in self.bioContent {
      let (contentContainerView, intrinsicHeight) = createBioContentItem(bioText: contentItem.bio,
                                                                         creatorName: contentItem.creatorName)
      
      self.intrinsicContentHeights.append(intrinsicHeight)
      contentContainerView.translatesAutoresizingMaskIntoConstraints = false
      self.scrollView.addSubview(contentContainerView)
      self.scrollView.addConstraints([
        NSLayoutConstraint(item: contentContainerView, attribute: .width, relatedBy: .equal,
                           toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: contentContainerView, attribute: .centerX, relatedBy: .equal,
                           toItem: self.scrollView, attribute: .centerX, multiplier: 1.0 + (2.0 * itemNumber), constant: 0.0),
        NSLayoutConstraint(item: contentContainerView, attribute: .centerY, relatedBy: .equal,
                           toItem: self.scrollView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: contentContainerView, attribute: .height, relatedBy: .equal,
                           toItem: self.scrollView, attribute: .height, multiplier: 1.0, constant: 0.0)
        ])
      itemNumber += 1.0
    }
    
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * itemNumber, height: 0)
    self.scrollViewHeightConstraint.constant = self.intrinsicContentHeights.first!
  }
  
  func createBioContentItem(bioText: String, creatorName: String) -> (view: UIView, intrinsicHeight: CGFloat) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    let indentWidth: CGFloat = 20.0
    
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
    
    let containerSize = CGSize(width: self.view.frame.width - (2 * indentWidth), height: CGFloat.infinity)
    let intrinsicContentHeight: CGFloat = contentTextLabel.sizeThatFits(containerSize).height + 38
      + writtenByLabel.sizeThatFits(containerSize).height
    
    return (containerView, intrinsicContentHeight)
  }
  
}

// MARK: - ScrollViewDelegate
extension ProfileBioViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageIndex: Int = Int(floor(scrollView.contentOffset.x / scrollView.frame.width))
    let pagePercentage: CGFloat = scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.frame.width) / scrollView.frame.width
    if pageIndex < self.intrinsicContentHeights.count - 1 && pageIndex >= 0 {
      let newScrollViewHeight = self.intrinsicContentHeights[pageIndex] * (1 - pagePercentage) +
        self.intrinsicContentHeights[pageIndex + 1] * pagePercentage
      self.scrollViewHeightConstraint.constant = newScrollViewHeight + 40
      self.view.layoutIfNeeded()
    }
  }
  
}
