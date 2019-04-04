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
  var bioView: BioView!
  var doView: DoDontView!
  var dontView: DoDontView!
  
  @IBOutlet weak var contentScrollView: UIScrollView!
  @IBOutlet weak var contentStackView: UIStackView!
  @IBOutlet weak var itemsStackView: UIStackView!
  @IBOutlet weak var gradientView: UIView!
  @IBOutlet weak var cardView: UIView!
  @IBOutlet weak var cardShadowView: UIView!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var forwardButton: UIButton!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var infoStackView: UIStackView!
  @IBOutlet weak var infoScrollView: UIScrollView!
  @IBOutlet weak var suggestedForLabel: UILabel!
  @IBOutlet weak var suggestedForContainer: UIView!
  
  let indentWidth: CGFloat = 20.0
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.setupContentViews()
    self.setupScrollView()
    self.stylize()
  }
  
  func stylize() {
    let gradient = CAGradientLayer()
    gradient.frame = CGRect(origin: CGPoint.zero, size: self.gradientView.frame.size)
    gradient.colors = [UIColor(white: 0.0, alpha: 0.0).cgColor, UIColor(white: 0.0, alpha: 0.08).cgColor]
    
    if let nameFont = R.font.nunitoSemiBold(size: 22) {
      self.nameLabel.font = nameFont
    }
    self.gradientView.layer.insertSublayer(gradient, at: 0)
    self.infoStackView.layoutMargins = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    self.infoStackView.isLayoutMarginsRelativeArrangement = true
    self.suggestedForLabel.stylizeInfoSubtextLabel()
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
    self.contentScrollView.showsHorizontalScrollIndicator = false
    let forwardSwipe = UISwipeGestureRecognizer(target: self, action: #selector(DiscoveryTableViewCell.forwardButtonClicked(_:)))
    let forwardSwipe2 = UISwipeGestureRecognizer(target: self, action: #selector(DiscoveryTableViewCell.forwardButtonClicked(_:)))
    forwardSwipe.direction = .left
    forwardSwipe2.direction = .left
    let backwardSwipe = UISwipeGestureRecognizer(target: self, action: #selector(DiscoveryTableViewCell.backButtonClicked(_:)))
    let backwardSwipe2 = UISwipeGestureRecognizer(target: self, action: #selector(DiscoveryTableViewCell.backButtonClicked(_:)))
    backwardSwipe.direction = .right
    backwardSwipe2.direction = .right
    self.backButton.addGestureRecognizer(forwardSwipe)
    self.backButton.addGestureRecognizer(backwardSwipe)
    self.forwardButton.addGestureRecognizer(forwardSwipe2)
    self.forwardButton.addGestureRecognizer(backwardSwipe2)
  }
  
  @objc func handlePanGestureRecognizer(panRecognizer: UIPanGestureRecognizer) {
    guard panRecognizer.view != nil else {return}
    let piece = panRecognizer.view!
    let translation = panRecognizer.translation(in: piece.superview)
    if panRecognizer.state != .cancelled {
      self.contentScrollView
        .setContentOffset(CGPoint(x: self.contentScrollView.contentOffset.x - translation.x,
                                  y: self.contentScrollView.contentOffset.y), animated: false)
      if let panDelegate = self.delegate {
        panDelegate.receivedVerticalPanTranslation(yTranslation: translation.y)
      }
      panRecognizer.setTranslation(CGPoint.zero, in: nil)
    }
    if panRecognizer.state == .ended {
      var pageIndex = round(self.contentScrollView.contentOffset.x / self.contentScrollView.frame.width)
      let velocity = panRecognizer.velocity(in: piece.superview)
      let velocityThreshold: CGFloat = 150
      if velocity.x < velocityThreshold &&
        pageIndex * self.contentScrollView.frame.width < self.contentScrollView.contentOffset.x &&
        pageIndex * self.contentScrollView.frame.width + self.contentScrollView.frame.width / 2.0 > self.contentScrollView.contentOffset.x {
        pageIndex += 1
      } else if velocity.x > velocityThreshold && pageIndex > 0 &&
        pageIndex * self.contentScrollView.frame.width > self.contentScrollView.contentOffset.x &&
        pageIndex * self.contentScrollView.frame.width - self.contentScrollView.frame.width / 2.0 < self.contentScrollView.contentOffset.x {
        pageIndex -= 1
      }
      if let panDelegate = self.delegate {
        panDelegate.endedVerticalPanTranslation(yVelocity: velocity.y)
      }
      self.contentScrollView
        .setContentOffset(CGPoint(x: pageIndex * self.contentScrollView.frame.width, y: 0), animated: true)
    }
    
  }
  
  func highlightIndicator(index: Int) {
    let imageHighlightColor = UIColor(white: 1.0, alpha: 0.7)
    let imageTintColor = UIColor(white: 1.0, alpha: 0.25)
    let textHightlightColor = UIColor(white: 0.0, alpha: 0.3)
    let textTintColor = UIColor(white: 0.0, alpha: 0.1)
    var indexView: UIView?
    var indexCount = 0
    for contentView in self.contentStackView.arrangedSubviews where !contentView.isHidden {
      if indexCount == index {
        indexView = contentView
        break
      }
      indexCount += 1
    }
    if let indexView = indexView {
      
      switch indexView {
      case is UIImageView:
        self.indicatorViews.forEach({ $0.backgroundColor = imageTintColor })
        if index < self.indicatorViews.count {
          self.indicatorViews[index].backgroundColor = imageHighlightColor
        }
      case is BioView, is DoDontView:
        self.indicatorViews.forEach({ $0.backgroundColor = textTintColor })
        if index < self.indicatorViews.count {
          self.indicatorViews[index].backgroundColor = textHightlightColor
        }
      default:
        break
        
      }
    }
    
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.pageChange(forward: false)
  }
  
  @IBAction func forwardButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.pageChange(forward: true)
  }
  
  func pageChange(forward: Bool) {
    var pageIndex = round(self.contentScrollView.contentOffset.x / self.contentScrollView.frame.width)
    if forward {
      pageIndex += 1
    } else if pageIndex > 0 {
      pageIndex -= 1
    }
    let numPages = self.contentStackView.arrangedSubviews.filter({ !$0.isHidden }).count
    if Int(pageIndex) >= numPages,
      let triggerDelegate = self.delegate {
      triggerDelegate.fullProfileViewTriggered(profileData: self.profileData)
    }
    
    var pageFrame = self.contentScrollView.frame
    pageFrame.origin.x = pageIndex * self.contentScrollView.frame.width
    pageFrame.origin.y = 0
    self.contentScrollView.scrollRectToVisible(pageFrame, animated: true)
    
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}

// MARK: - Cell Configuration
extension DiscoveryTableViewCell {
  func configureInfo(profileData: FullProfileDisplayData) {
    if let firstName = profileData.firstName,
      let age = profileData.age {
      self.nameLabel.text = "\(firstName), \(age)"
    }
    self.infoStackView.arrangedSubviews.forEach({
      $0.removeFromSuperview()
      self.infoStackView.removeArrangedSubview($0)
    })
    if let locationName = profileData.locationName {
      let containerView = UIView()
      
      let locationIconView = UIImageView(image: R.image.discoveryIconLocation())
      locationIconView.translatesAutoresizingMaskIntoConstraints = false
      locationIconView.contentMode = .scaleAspectFit
      containerView.addSubview(locationIconView)
      locationIconView.addConstraints([
        NSLayoutConstraint(item: locationIconView, attribute: .width, relatedBy: .equal,
                           toItem: locationIconView, attribute: .height, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: locationIconView, attribute: .width, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 18)
        ])
      let locationLabel = UILabel()
      containerView.addSubview(locationLabel)
      locationLabel.translatesAutoresizingMaskIntoConstraints = false
      locationLabel.stylizeInfoSubtextLabel()
      locationLabel.text = locationName
      containerView.addConstraints([
        NSLayoutConstraint(item: locationIconView, attribute: .left, relatedBy: .equal,
                           toItem: containerView, attribute: .left, multiplier: 1.0, constant: 2),
        NSLayoutConstraint(item: locationIconView, attribute: .right, relatedBy: .equal,
                           toItem: locationLabel, attribute: .left, multiplier: 1.0, constant: -2),
        NSLayoutConstraint(item: locationIconView, attribute: .bottom, relatedBy: .equal,
                           toItem: locationLabel, attribute: .firstBaseline, multiplier: 1.0, constant: 2),
        NSLayoutConstraint(item: locationLabel, attribute: .right, relatedBy: .equal,
                           toItem: containerView, attribute: .right, multiplier: 1.0, constant: -6),
        NSLayoutConstraint(item: locationLabel, attribute: .top, relatedBy: .equal,
                           toItem: containerView, attribute: .top, multiplier: 1.0, constant: 2),
        NSLayoutConstraint(item: locationLabel, attribute: .bottom, relatedBy: .equal,
                           toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0)
        ])
      self.infoStackView.addArrangedSubview(containerView)
    }
    
    if let schoolName = profileData.school {
      let containerView = UIView()
      
      let schoolIconView = UIImageView(image: R.image.discoveryIconSchool())
      schoolIconView.translatesAutoresizingMaskIntoConstraints = false
      schoolIconView.contentMode = .scaleAspectFit
      containerView.addSubview(schoolIconView)
      schoolIconView.addConstraints([
        NSLayoutConstraint(item: schoolIconView, attribute: .width, relatedBy: .equal,
                           toItem: schoolIconView, attribute: .height, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: schoolIconView, attribute: .width, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 18)
        ])
      let schoolLabel = UILabel()
      containerView.addSubview(schoolLabel)
      schoolLabel.translatesAutoresizingMaskIntoConstraints = false
      schoolLabel.stylizeInfoSubtextLabel()
      schoolLabel.text = schoolName
      containerView.addConstraints([
        NSLayoutConstraint(item: schoolIconView, attribute: .left, relatedBy: .equal,
                           toItem: containerView, attribute: .left, multiplier: 1.0, constant: 2),
        NSLayoutConstraint(item: schoolIconView, attribute: .right, relatedBy: .equal,
                           toItem: schoolLabel, attribute: .left, multiplier: 1.0, constant: -4),
        NSLayoutConstraint(item: schoolIconView, attribute: .bottom, relatedBy: .equal,
                           toItem: schoolLabel, attribute: .firstBaseline, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: schoolLabel, attribute: .right, relatedBy: .equal,
                           toItem: containerView, attribute: .right, multiplier: 1.0, constant: -6),
        NSLayoutConstraint(item: schoolLabel, attribute: .top, relatedBy: .equal,
                           toItem: containerView, attribute: .top, multiplier: 1.0, constant: 2),
        NSLayoutConstraint(item: schoolLabel, attribute: .bottom, relatedBy: .equal,
                           toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0)
        ])
      self.infoStackView.addArrangedSubview(containerView)
    }
    if self.infoStackView.arrangedSubviews.count > 0 {
      self.infoScrollView.isHidden = false
    } else {
      self.infoScrollView.isHidden = true
    }
    
    var suggestedFor: [String] = []
    if let matchingDemographics = profileData.matchingDemographics,
      let matchingPreferences = profileData.matchingPreferences {
      for endorsedUser in DataStore.shared.endorsedUsers {
        if endorsedUser.matchingPreferences.matchesDemographics(demographics: matchingDemographics) &&
          matchingPreferences.matchesDemographics(demographics: endorsedUser.matchingDemographics) {
          suggestedFor.append(endorsedUser.firstName)
        }
      }
//      for detachedProfile in DataStore.shared.detachedProfiles {
//        if detachedProfile.matchingPreferences.matchesDemographics(demographics: matchingDemographics) &&
//          matchingPreferences.matchesDemographics(demographics: detachedProfile.matchingDemographics) {
//          suggestedFor.append(detachedProfile.firstName)
//        }
//      }
    }
    if suggestedFor.count > 0 {
      self.suggestedForContainer.isHidden = false
      self.suggestedForLabel.text = "Suggested for " + suggestedFor.joined(separator: ", ")
    } else {
      self.suggestedForContainer.isHidden = true
    }
    
  }
  
  func configureCell(profileData: FullProfileDisplayData) {
    self.layoutIfNeeded()
    self.configureInfo(profileData: profileData)
    self.profileData = profileData
    self.contentScrollView.contentOffset = CGPoint.zero
    self.indicatorViews.forEach({
      $0.removeFromSuperview()
    })
    self.indicatorViews = []
    
    var pagesCount = 0
    for index in 0..<3 {
      let imageView = self.imageViews[index]
      imageView.image = nil
      if index < profileData.rawImages.count {
        imageView.image = profileData.rawImages[index]
        imageView.isHidden = false
        pagesCount += 1
      } else if index < profileData.imageContainers.count,
        let imageURL = URL(string: profileData.imageContainers[index].medium.imageURL) {
        imageView.sd_setImage(with: imageURL, completed: nil)
        imageView.isHidden = false
        pagesCount += 1
      } else {
        imageView.isHidden = true
      }
    }
    if let bioContent = profileData.bio.first {
      self.bioView.isHidden = false
      self.bioView.writtenByLabel?.stylizeCreatorLabel(preText: "Written by ", boldText: bioContent.creatorName)
      self.bioView.contentLabel?.text = bioContent.bio
      pagesCount += 1
    } else {
      self.bioView.isHidden = true
    }
    if let doContent = profileData.dos.first {
      self.doView.isHidden = false
      self.doView.writtenByLabel?.stylizeCreatorLabel(preText: "Written by ", boldText: doContent.creatorName)
      self.doView.contentLabel?.text = doContent.phrase
      pagesCount += 1
    } else {
      self.doView.isHidden = true
    }
    if let dontContent = profileData.donts.first {
      self.dontView.isHidden = false
      self.dontView.writtenByLabel?.stylizeCreatorLabel(preText: "Written by ", boldText: dontContent.creatorName)
      self.dontView.contentLabel?.text = dontContent.phrase
      pagesCount += 1
    } else {
      self.dontView.isHidden = true
    }
    
    let indicatorSpacing: CGFloat = 8
    let indicatorWidth: CGFloat = (self.contentScrollView.frame.width - (CGFloat(pagesCount + 1) * indicatorSpacing)) / CGFloat(pagesCount)
    let totalItemWidth = indicatorSpacing + indicatorWidth
    for index in 0..<pagesCount {
      let indicatorView = UIView(frame: CGRect(x: indicatorSpacing + totalItemWidth * CGFloat(index) ,
                                               y: self.contentScrollView.frame.height - 8,
                                               width: indicatorWidth,
                                               height: 4))
      indicatorView.layer.cornerRadius = 2
      self.indicatorViews.append(indicatorView)
      self.itemsStackView.addSubview(indicatorView)
    }
    self.highlightIndicator(index: 0)
  }

}

// MARK: - UIScrollViewDelegate
extension DiscoveryTableViewCell: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
    self.highlightIndicator(index: Int(pageIndex))
    let numPages = self.contentStackView.arrangedSubviews.filter({ !$0.isHidden }).count
    if pageIndex >= CGFloat(numPages), let triggerDelegate = self.delegate {
      triggerDelegate.fullProfileViewTriggered(profileData: self.profileData)
    }
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
    contentTextLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    contentTextLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    containerView.addSubview(contentTextLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: contentTextLabel, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: indentWidth),
      NSLayoutConstraint(item: contentTextLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -indentWidth),
      NSLayoutConstraint(item: contentTextLabel, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 8.0)
      ])
    
    let writtenByLabel = UILabel()
    writtenByLabel.stylizeCreatorLabel(preText: "Written by ", boldText: creatorName)
    writtenByLabel.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(writtenByLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: writtenByLabel, attribute: .top, relatedBy: .equal,
                         toItem: contentTextLabel, attribute: .bottom, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: writtenByLabel, attribute: .bottom, relatedBy: .lessThanOrEqual,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -20.0)
      
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
    
    let iconImageView = UIImageView()
    iconImageView.translatesAutoresizingMaskIntoConstraints = false
    iconImageView.contentMode = .scaleAspectFit
    containerView.addSubview(iconImageView)
    
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.stylizeProfileSectionTitleLabel()
    containerView.addSubview(titleLabel)
    
    containerView.addConstraints([
      NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal,
                         toItem: iconImageView, attribute: .right, multiplier: 1.0, constant: 12),
      NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -16),
      NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 26),
      NSLayoutConstraint(item: iconImageView, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: 8),
      NSLayoutConstraint(item: iconImageView, attribute: .width, relatedBy: .equal,
                         toItem: iconImageView, attribute: .height, multiplier: 1.0, constant: 0),
      NSLayoutConstraint(item: iconImageView, attribute: .width, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 46),
      NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal,
                         toItem: titleLabel, attribute: .centerY, multiplier: 1.0, constant: 0)
      ])
    
    var fullContentText = ""
    switch type {
    case .doType:
      iconImageView.image = R.image.profileIconDo()
      titleLabel.text = "Do"
      fullContentText += contentText
    case .dontType:
      iconImageView.image = R.image.profileIconDont()
      titleLabel.text = "Don't"
      fullContentText += contentText
    }
    
    let contentTextLabel = UILabel()
    contentTextLabel.numberOfLines = 0
    contentTextLabel.text = fullContentText
    contentTextLabel.stylizeDoDontLabel()
    contentTextLabel.translatesAutoresizingMaskIntoConstraints = false
    contentTextLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    contentTextLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    containerView.addSubview(contentTextLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: contentTextLabel, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: indentWidth),
      NSLayoutConstraint(item: contentTextLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -indentWidth),
      NSLayoutConstraint(item: contentTextLabel, attribute: .top, relatedBy: .equal,
                         toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 12.0)
      ])
    
    let writtenByLabel = UILabel()
    writtenByLabel.stylizeCreatorLabel(preText: "Written by ", boldText: creatorName)
    writtenByLabel.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(writtenByLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: writtenByLabel, attribute: .top, relatedBy: .equal,
                         toItem: contentTextLabel, attribute: .bottom, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: writtenByLabel, attribute: .bottom, relatedBy: .lessThanOrEqual,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -20.0)
      
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
