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
        SentryHelper.generateSentryEvent(message: "Failed to send match request from:\(personalUserID) to:\(self.profileID!)")
        switch error {
        case .graphQLError(let message):
          break
        default:
          break
        }
        
      }
    }
    
  }
  
}
