//
//  DiscoveryPersonalFullProfileViewController.swift
//  Pear
//
//  Created by Avery Lamp on 7/7/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

class DiscoveryPersonalFullProfileViewController: DiscoveryFullProfileViewController {
  
  static let likeButtonSize: CGFloat = 50.0
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(fullProfileData: FullProfileDisplayData) -> DiscoveryPersonalFullProfileViewController? {
    guard let fullDiscoveryVC = R.storyboard.discoveryPersonalFullProfileViewController
      .instantiateInitialViewController() else { return nil }
    fullDiscoveryVC.fullProfileData = fullProfileData
    guard let matchingUserObject = fullProfileData.originObject as? PearUser else {
      print("Failed to get matching user object from full profile")
      return nil
    }
    fullDiscoveryVC.profileID = matchingUserObject.documentID
    return fullDiscoveryVC
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.addLikesButtons()
    self.addIncompleteProfileIfNeeded()
  }
  
  @objc func personalRequestButtonClicked(_ sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.sendLike(likeButtonIndex: sender.tag)
  }
  
  func addLikesButtons() {
    guard let fullProfileStackVC = self.fullProfileStackVC else {
      print("Unable to find full Profile Stack VC")
      return
    }
    for index in 0..<fullProfileStackVC.sectionItemsWithVCs.count {
      let sectionItemWithVC = fullProfileStackVC.sectionItemsWithVCs[index]
      let sectionView = sectionItemWithVC.viewController.view
      let likeButton = UIButton()
      likeButton.tag = index
      likeButton.addTarget(self, action: #selector(DiscoveryPersonalFullProfileViewController.personalRequestButtonClicked(_:)), for: .touchUpInside)
      likeButton.translatesAutoresizingMaskIntoConstraints = false
      likeButton.setImage(R.image.discoveryIconLike(), for: .normal)
      likeButton.setImage(R.image.discoveryIconLike(), for: .selected)
      self.stylizeActionButton(button: likeButton)
      likeButton.layer.cornerRadius = DiscoveryPersonalFullProfileViewController.likeButtonSize / 2.0
      fullProfileStackVC.view.addSubview(likeButton)
      
      likeButton.addConstraints([
        NSLayoutConstraint(item: likeButton, attribute: .width, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0,
                           constant: DiscoveryPersonalFullProfileViewController.likeButtonSize),
        NSLayoutConstraint(item: likeButton, attribute: .height, relatedBy: .equal,
                           toItem: likeButton, attribute: .width, multiplier: 1.0, constant: 0.0)
        ])
      fullProfileStackVC.view.addConstraints([
        NSLayoutConstraint(item: likeButton, attribute: .bottom, relatedBy: .equal,
                           toItem: sectionView, attribute: .bottom, multiplier: 1.0, constant: -12.0),
        NSLayoutConstraint(item: likeButton, attribute: .right, relatedBy: .equal,
                           toItem: sectionView, attribute: .right, multiplier: 1.0, constant: -12.0)
        ])
    }

  }
  
  func addIncompleteProfileIfNeeded() {
    if let numberPrompts = DataStore.shared.getCurrentFilterUser()?.questionResponses.count {
      if numberPrompts == 0 {
        self.addIncompleteProfileHeader(ctaText: "People with complete profiles get 3-5x more matches")
      } else if numberPrompts < 3 {
        self.addIncompleteProfileHeader(ctaText: "People with complete profiles get 3-5x more matches")
      }      
    }
  }
  
  @objc func completeProfileBannerClicked(sender: UIButton) {
    SlackHelper.shared.addEvent(text: "Incomplete Profile Banner Clicked (no-op for now)", color: UIColor.green)
  }
  
  func addIncompleteProfileHeader(ctaText: String) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    let headerButton = UIButton()
    headerButton.addTarget(self,
                           action: #selector(DiscoveryPersonalFullProfileViewController.completeProfileBannerClicked(sender:)),
                           for: .touchUpInside)
    headerButton.translatesAutoresizingMaskIntoConstraints = false
    headerButton.setImage(R.image.discoveryIncompleteProfileHeaderBackground(), for: .normal)
    headerButton.layer.cornerRadius = 12.0
    headerButton.clipsToBounds = true
    let headerShadowView = UIView()
    headerShadowView.translatesAutoresizingMaskIntoConstraints = false
    headerShadowView.backgroundColor = UIColor.white
    headerShadowView.layer.cornerRadius = 12.0
    headerShadowView.layer.shadowRadius = 12.0
    headerShadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
    headerShadowView.layer.shadowColor = UIColor(red: 0.90, green: 0.89, blue: 0.86, alpha: 1.00).cgColor
    headerShadowView.layer.shadowOpacity = 1.0
    containerView.addSubview(headerShadowView)
    containerView.addSubview(headerButton)
    
    // Header View Constraints
    containerView.addConstraints([
      NSLayoutConstraint(item: headerButton, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: headerButton, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -12.0),
      NSLayoutConstraint(item: headerButton, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 10.0),
      NSLayoutConstraint(item: headerButton, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -10.0)
//      NSLayoutConstraint(item: headerButton, attribute: .height, relatedBy: .equal,
//                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60.0)
      ])
    
    // Header Shadow Constraints
    containerView.addConstraints([
      NSLayoutConstraint(item: headerShadowView, attribute: .centerX, relatedBy: .equal,
                         toItem: headerButton, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: headerShadowView, attribute: .centerY, relatedBy: .equal,
                         toItem: headerButton, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: headerShadowView, attribute: .height, relatedBy: .equal,
                         toItem: headerButton, attribute: .height, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: headerShadowView, attribute: .width, relatedBy: .equal,
                         toItem: headerButton, attribute: .width, multiplier: 1.0, constant: 0.0)
      ])
    
    // Header Icon
    let headerIcon = UIImageView()
    headerIcon.translatesAutoresizingMaskIntoConstraints = false
    headerIcon.contentMode = .scaleAspectFill
    headerIcon.image = R.image.discoveryIncompleteProfileHeaderIcon()
    headerButton.addSubview(headerIcon)
    
    // Header Constraints
    headerIcon.addConstraints([
      NSLayoutConstraint(item: headerIcon, attribute: .width, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 32.0),
      NSLayoutConstraint(item: headerIcon, attribute: .width, relatedBy: .equal,
                         toItem: headerIcon, attribute: .height, multiplier: 1.0, constant: 0.0)
      ])
    headerButton.addConstraints([
      NSLayoutConstraint(item: headerIcon, attribute: .left, relatedBy: .equal,
                         toItem: headerButton, attribute: .left, multiplier: 1.0, constant: 16.0),
      NSLayoutConstraint(item: headerIcon, attribute: .top, relatedBy: .equal,
                         toItem: headerButton, attribute: .top, multiplier: 1.0, constant: 16.0)
      ])
    
    let headerCTALabel = UILabel()
    headerCTALabel.translatesAutoresizingMaskIntoConstraints = false
    headerCTALabel.text = ctaText
    headerCTALabel.textColor = R.color.primaryTextColor()
    headerCTALabel.numberOfLines = 0
    if let font = R.font.openSansSemiBold(size: 14) {
      headerCTALabel.font = font
    }
    headerCTALabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    headerButton.addSubview(headerCTALabel)
    headerButton.addConstraints([
      NSLayoutConstraint(item: headerCTALabel, attribute: .top, relatedBy: .equal,
                         toItem: headerIcon, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: headerCTALabel, attribute: .left, relatedBy: .equal,
                         toItem: headerIcon, attribute: .right, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: headerCTALabel, attribute: .right, relatedBy: .equal,
                         toItem: headerButton, attribute: .right, multiplier: 1.0, constant: -12.0)
      ])
    
    let headerCTASubtitleLabel = UILabel()
    headerCTASubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    headerCTASubtitleLabel.text = "COMPLETE YOUR PROFILE"
    headerCTASubtitleLabel.textColor = UIColor(red: 0.95, green: 0.62, blue: 0.26, alpha: 1.00)
    headerCTASubtitleLabel.numberOfLines = 1
    if let font = R.font.openSansExtraBold(size: 12) {
      headerCTASubtitleLabel.font = font
    }
    headerCTASubtitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    headerButton.addSubview(headerCTASubtitleLabel)
    headerButton.addConstraints([
      NSLayoutConstraint(item: headerCTASubtitleLabel, attribute: .top, relatedBy: .equal,
                         toItem: headerCTALabel, attribute: .bottom, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: headerCTASubtitleLabel, attribute: .left, relatedBy: .equal,
                         toItem: headerCTALabel, attribute: .left, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: headerCTASubtitleLabel, attribute: .right, relatedBy: .equal,
                         toItem: headerCTALabel, attribute: .right, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: headerCTASubtitleLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: headerButton, attribute: .bottom, multiplier: 1.0, constant: -16.0)
      ])
    
    self.fullProfileStackVC?.stackView.insertArrangedSubview(containerView, at: 0)
  }
  
}

// MARK: - Send Like
extension DiscoveryPersonalFullProfileViewController {
  
  func sendLike(likeButtonIndex: Int) {
    guard let personalUserID = DataStore.shared.currentPearUser?.documentID else {
      print("Unable to get current user")
      return
    }
    let matchRequestData = MatchRequestCreationData(sentByUserID: personalUserID,
                                                    sentForUserID: personalUserID,
                                                    receivedByUserID: self.profileID,
                                                    requestText: nil,
                                                    likedPhoto: nil,
                                                    likedPrompt: nil)
    if let fullProfileSectionVCs = fullProfileStackVC?.sectionItemsWithVCs,
      likeButtonIndex < fullProfileSectionVCs.count {
      let fullProfileSection = fullProfileSectionVCs[likeButtonIndex]
      matchRequestData.likedPhoto = fullProfileSection.sectionItem.image
      matchRequestData.likedPrompt = fullProfileSection.sectionItem.question
    }
    
    guard !isSendingRequest else {
      print("Is already sending request")
      return
    }
    self.isSendingRequest = true
    if let delegate = self.delegate {
      self.fullProfileData.decisionMade = true
      delegate.decisionMade()
    }
    SlackHelper.shared.addEvent(text: "User Sent Personal Request. to profile: \(self.fullProfileData.slackHelperSummary()), Liked Index \(likeButtonIndex), Liked Part: \(matchRequestData.likedPhoto != nil ? "Photo" : "Prompt") \(self.slackHelperDetails())", color: UIColor.green)
    PearMatchesAPI.shared.createMatchRequest(matchCreationData: matchRequestData) { (result) in
      switch result {
      case .success:
        break
      case .failure(let error):
        print("Error creating Request: \(error)")
      }
    }
    
  }
  
}
