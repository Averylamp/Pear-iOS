//
//  ProfileDoDontViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

enum DoDontType {
  case doType
  case dontType
}

struct DoDontContent {
  let phrase: String
  let creatorName: String
}

class ProfileDoDontViewController: UIViewController {
  
  @IBOutlet weak var titleImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pageControl: UIPageControl!
  
  var intrinsicContentHeights: [CGFloat] = []
  var doDontType: DoDontType!
  var doDontContent: [DoDontContent] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(doDontType: DoDontType, doDontContent: [DoDontContent]) -> ProfileDoDontViewController? {
    let storyboard = UIStoryboard(name: String(describing: ProfileDoDontViewController.self), bundle: nil)
    guard let doDontVC = storyboard.instantiateInitialViewController() as? ProfileDoDontViewController else { return nil }
    doDontVC.doDontType = doDontType
    doDontVC.doDontContent = doDontContent
    return doDontVC
  }
  
}

// MARK: - Life Cycle
extension ProfileDoDontViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.layoutIfNeeded()
    self.stylize()
    self.addDoDontContent()
    self.scrollView.delegate = self
  }
  
  func stylize() {
    self.titleLabel.stylizeProfileSectionTitleLabel()
    
    switch self.doDontType! {
    case .doType:
      self.titleImageView.image = UIImage(named: "profile-icon-do")
      self.titleLabel.text = "Do's"
    case .dontType:
      self.titleImageView.image = UIImage(named: "profile-icon-dont")
      self.titleLabel.text = "Dont's"
    }
    
    self.scrollView.isPagingEnabled = true
    self.scrollView.showsHorizontalScrollIndicator = true
    self.scrollView.showsVerticalScrollIndicator = false
    pageControl.numberOfPages = self.doDontContent.count
    
  }
  
  func addDoDontContent() {
    var itemNumber: CGFloat = 0
    for contentText in self.doDontContent {
      let (contentContainerView, intrinsicHeight) = createDoDontContentItem(contentText: contentText.phrase,
                                                                            creatorName: contentText.creatorName,
                                                                            type: self.doDontType)
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
    self.scrollViewHeightConstraint.constant = self.intrinsicContentHeights.first! + 24
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.scrollView.contentSize = CGSize(width: self.view.frame.width * CGFloat(self.intrinsicContentHeights.count),
                                         height: 0)
    self.scrollViewDidScroll(self.scrollView)
  }
  
  func createDoDontContentItem(contentText: String, creatorName: String, type: DoDontType) -> (view: UIView, intrinsicHeight: CGFloat) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    var fullContentText = ""
    switch type {
    case .doType:
      fullContentText += contentText
    case .dontType:
      fullContentText += contentText
    }
    
    let indentWidth: CGFloat = 20.0
    
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
    
    let containerSize = CGSize(width: self.view.frame.width - (2 * indentWidth), height: CGFloat.infinity)
    let intrinsicContentHeight: CGFloat = contentTextLabel.sizeThatFits(containerSize).height + 28
      + writtenByLabel.sizeThatFits(containerSize).height
    
    return (containerView, intrinsicContentHeight)
  }
}

// MARK: - ScrollViewDelegate
extension ProfileDoDontViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageIndex: Int = Int(floor(scrollView.contentOffset.x / scrollView.frame.width))
    self.pageControl.currentPage = pageIndex
    let pagePercentage: CGFloat = scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.frame.width) / scrollView.frame.width
    if pageIndex < self.intrinsicContentHeights.count - 1 && pageIndex >= 0 {
      let newScrollViewHeight = self.intrinsicContentHeights[pageIndex] * (1 - pagePercentage) +
        self.intrinsicContentHeights[pageIndex + 1] * pagePercentage
      self.scrollViewHeightConstraint.constant = newScrollViewHeight + 24
      self.view.layoutIfNeeded()
    }
  }
}
