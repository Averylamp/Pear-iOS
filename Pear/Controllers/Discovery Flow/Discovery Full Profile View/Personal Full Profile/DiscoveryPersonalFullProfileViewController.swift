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
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(fullProfileData: FullProfileDisplayData!) -> DiscoveryPersonalFullProfileViewController? {
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
    
  }
  
  @objc func personalRequestButtonClicked(_ sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let requestedThumbnailString = self.fullProfileData.imageContainers.first?.thumbnail.imageURL,
      let requestedThumbnailURL = URL(string: requestedThumbnailString) else {
        print("Failed to pull relavant discover user fields")
        return
    }
    guard let personalUserID = DataStore.shared.currentPearUser?.documentID else {
      print("Failed to get personal User ID")
      return
    }
    if let profileCount = DataStore.shared.currentPearUser?.endorserIDs.count,
      profileCount ==  0 && Int.random(in: 0..<5) == 0 {
      self.promptProfileRequest()
    } else {
      //      self.displayPersonalRequestVC(personalUserID: personalUserID,
      //                                    thumbnailImageURL: requestedThumbnailURL,
      //                                    requestPersonName: self.fullProfileData.firstName ?? "")
      // self.createPearRequest(sentByUserID: personalUserID, sentForUserID: personalUserID, requestText: nil)
    }
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
      likeButton.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
      likeButton.layer.cornerRadius = 24
      likeButton.clipsToBounds = true
      fullProfileStackVC.view.addSubview(likeButton)
      let shadowView = UIView()
      shadowView.translatesAutoresizingMaskIntoConstraints = false
      shadowView.layer.cornerRadius = 24
      shadowView.backgroundColor = UIColor.white
      shadowView.layer.shadowOpacity = 0.15
      shadowView.layer.shadowColor = UIColor.black.cgColor
      shadowView.layer.shadowRadius = 6
      shadowView.layer.shadowOffset = CGSize(width: 3, height: 3 )
      fullProfileStackVC.view.insertSubview(shadowView, belowSubview: likeButton)
      likeButton.addConstraints([
        NSLayoutConstraint(item: likeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 48),
        NSLayoutConstraint(item: likeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 48)
        ])
      fullProfileStackVC.view.addConstraints([
        NSLayoutConstraint(item: likeButton, attribute: .bottom, relatedBy: .equal,
                           toItem: sectionView, attribute: .bottom, multiplier: 1.0, constant: -12.0),
        NSLayoutConstraint(item: likeButton, attribute: .right, relatedBy: .equal,
                           toItem: sectionView, attribute: .right, multiplier: 1.0, constant: -12.0),
        NSLayoutConstraint(item: shadowView, attribute: .height, relatedBy: .equal,
                           toItem: likeButton, attribute: .height, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: shadowView, attribute: .width, relatedBy: .equal,
                           toItem: likeButton, attribute: .width, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: shadowView, attribute: .centerX, relatedBy: .equal,
                           toItem: likeButton, attribute: .centerX, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: shadowView, attribute: .centerY, relatedBy: .equal,
                           toItem: likeButton, attribute: .centerY, multiplier: 1.0, constant: 0)
        ])
    }

  }
  
}
