//
//  DiscoveryFullProfileViewController+MatchingButtons.swift
//  Pear
//
//  Created by Avery Lamp on 5/28/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

enum MatchingButtonType: Int {
  case personalUser = 0
  case placeholderEndorsed = 1
  case endorsedUser = 2
  case detachedProfile = 3
}

struct MatchButton {
  let button: UIButton
  let buttonEnabled: Bool
  let type: MatchingButtonType
  var endorsedUser: PearUser?
  var user: PearUser?
  var detachedProfile: PearDetachedProfile?
}

// MARK: - Matching Buttons
extension DiscoveryFullProfileViewController {
  
  func removeMatchButtons() {
    self.pearButton.isSelected = false
    UIView.animate(withDuration: 0.2, animations: {
      self.matchButtons.forEach {
        $0.button.alpha = 0.0
        $0.button.center.y += 10
      }
      self.matchButtonShadows.forEach({
        $0.alpha = 0.0
        $0.center.y += 10
      })
    }, completion: { (_) in
      self.matchButtons.forEach({ $0.button.removeFromSuperview() })
      self.matchButtons = []
      self.matchButtonShadows.forEach({ $0.removeFromSuperview() })
      self.matchButtonShadows = []
    })
  }
  
  func generateMatchButton(enabled: Bool) -> UIButton {
    let matchButton = UIButton()
    matchButton.translatesAutoresizingMaskIntoConstraints = false
    matchButton.layer.cornerRadius = 30
    matchButton.clipsToBounds = true
    matchButton.imageView?.contentMode = .scaleAspectFill
    matchButton.addTarget(self,
                          action: #selector(DiscoveryFullProfileViewController.matchOptionClicked(sender:)),
                          for: .touchUpInside)
    let shadowView = UIView()
    shadowView.translatesAutoresizingMaskIntoConstraints = false
    shadowView.layer.cornerRadius = 30
    shadowView.backgroundColor = UIColor.white
    shadowView.layer.shadowOpacity = 0.15
    shadowView.layer.shadowColor = UIColor.black.cgColor
    shadowView.layer.shadowRadius = 8
    shadowView.layer.shadowOffset = CGSize(width: 3, height: 3 )
    self.matchButtonShadows.append(shadowView)
    self.view.insertSubview(matchButton, belowSubview: self.pearButton)
    self.view.insertSubview(shadowView, belowSubview: matchButton)
    self.view.addConstraints([
      NSLayoutConstraint(item: matchButton, attribute: .width, relatedBy: .equal,
                         toItem: self.pearButton, attribute: .width, multiplier: 1.0, constant: 0),
      NSLayoutConstraint(item: matchButton, attribute: .height, relatedBy: .equal,
                         toItem: self.pearButton, attribute: .height, multiplier: 1.0, constant: 0),
      NSLayoutConstraint(item: shadowView, attribute: .height, relatedBy: .equal,
                         toItem: matchButton, attribute: .height, multiplier: 1.0, constant: 0),
      NSLayoutConstraint(item: shadowView, attribute: .width, relatedBy: .equal,
                         toItem: matchButton, attribute: .width, multiplier: 1.0, constant: 0),
      NSLayoutConstraint(item: shadowView, attribute: .centerX, relatedBy: .equal,
                         toItem: matchButton, attribute: .centerX, multiplier: 1.0, constant: 0),
      NSLayoutConstraint(item: shadowView, attribute: .centerY, relatedBy: .equal,
                         toItem: matchButton, attribute: .centerY, multiplier: 1.0, constant: 0)
      ])
    
    if !enabled {
      let darkeningView = UIView()
      darkeningView.isUserInteractionEnabled = false
      darkeningView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
      darkeningView.translatesAutoresizingMaskIntoConstraints = false
      matchButton.addSubview(darkeningView)
      matchButton.addConstraints([
        NSLayoutConstraint(item: darkeningView, attribute: .width, relatedBy: .equal,
                           toItem: matchButton, attribute: .width, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: darkeningView, attribute: .height, relatedBy: .equal,
                           toItem: matchButton, attribute: .height, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: darkeningView, attribute: .centerX, relatedBy: .equal,
                           toItem: matchButton, attribute: .centerX, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: darkeningView, attribute: .centerY, relatedBy: .equal,
                           toItem: matchButton, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
    }
    return matchButton
  }
  
  func createMatchButtons() -> [MatchButton] {
    let alreadyMatchedUsers = DataStore.shared.matchedUsersFromDefaults(userID: self.profileID)
    
    guard let discoveryUserPreferences = self.fullProfileData.matchingPreferences,
      let discoveryUserDemographics = self.fullProfileData.matchingDemographics else {
        print("Failed to get discovery user pref/demo")
        return []
    }
    
    let discoverySet = (preferences: discoveryUserPreferences, demographics: discoveryUserDemographics)
    
    var allMatchButtons: [MatchButton] = []
    
    for endorsedProfile in DataStore.shared.endorsedUsers {
      var endorsedEnabled = !alreadyMatchedUsers.contains(endorsedProfile.documentID)
      endorsedEnabled = endorsedEnabled && endorsedProfile.matchingPreferences.matchesDemographics(demographics: discoveryUserDemographics)
        && discoveryUserPreferences.matchesDemographics(demographics: endorsedProfile.matchingDemographics)
      let endorsedButton = self.generateMatchButton(enabled: endorsedEnabled)
      if let imageURLString = endorsedProfile.displayedImages.first?.thumbnail.imageURL,
        let imageURL = URL(string: imageURLString) {
        endorsedButton.sd_setImage(with: imageURL, for: .normal, completed: nil)
      } else {
        endorsedButton.setImage(R.image.discoveryPlacholderUserImage(), for: .normal)
      }
      let endorsedMatchButton = MatchButton(button: endorsedButton,
                                            buttonEnabled: endorsedEnabled,
                                            type: .endorsedUser,
                                            endorsedUser: endorsedProfile,
                                            user: nil,
                                            detachedProfile: nil)
      allMatchButtons.append(endorsedMatchButton)
    }
    
    for detachedProfile in DataStore.shared.detachedProfiles {
      let detachedProfileButton = self.generateMatchButton(enabled: false)
      if let imageURLString = detachedProfile.images.first?.thumbnail.imageURL,
        let imageURL = URL(string: imageURLString) {
        detachedProfileButton.sd_setImage(with: imageURL, for: .normal, completed: nil)
      } else {
        detachedProfileButton.setImage(R.image.discoveryPlacholderUserImage(), for: .normal)
      }
      let endorsedMatchButton = MatchButton(button: detachedProfileButton,
                                            buttonEnabled: false,
                                            type: .detachedProfile,
                                            endorsedUser: nil,
                                            user: nil,
                                            detachedProfile: detachedProfile)
      allMatchButtons.append(endorsedMatchButton)
    }
    
    allMatchButtons.sort { (matchButton1, matchButton2) -> Bool in
      guard let mat1 = getMatchingPrefDemoFromMatchButton(matchButton: matchButton1) else {
        print("Failed to get mat1 ")
        return false
      }
      guard let mat2 = getMatchingPrefDemoFromMatchButton(matchButton: matchButton2) else {
        print("Failed to get mat2 ")
        return true
      }
      if compareMatchingSet(set1: mat1, set2: discoverySet) != compareMatchingSet(set1: mat2, set2: discoverySet) {
        return compareMatchingSet(set1: mat1, set2: discoverySet)
      }
      
      // Ordering of user < endorsed < detached
      if matchButton1.type.rawValue < matchButton2.type.rawValue {
        return true
      } else if matchButton1.type.rawValue > matchButton2.type.rawValue {
        return false
      }
      
      return true
    }
    
    // Only You in match buttons, generate placeholder endorsed
    if allMatchButtons.count == 1 {
      let placeholderEndorsedButton = self.generateMatchButton(enabled: true)
      placeholderEndorsedButton.setImage(R.image.discoveryPlaceholderEndorsement(), for: .normal)
      
      let placeholderEndorsementButton = MatchButton(button: placeholderEndorsedButton,
                                                     buttonEnabled: true,
                                                     type: .placeholderEndorsed,
                                                     endorsedUser: nil,
                                                     user: nil,
                                                     detachedProfile: nil)
      allMatchButtons.append(placeholderEndorsementButton)
    }
    
    return allMatchButtons
  }
  
  func addMatchButtonsAnimated(matchButtons: [MatchButton]) {
    self.pearButton.isSelected = true
    var matchButtonYConstraints: [NSLayoutConstraint] = []
    matchButtons.forEach { (matchButton) in
      let centerYConstraint = NSLayoutConstraint(item: matchButton.button, attribute: .centerY, relatedBy: .equal,
                                                 toItem: self.pearButton, attribute: .centerY, multiplier: 1.0, constant: 0.0)
      matchButtonYConstraints.append(centerYConstraint)
      self.view.addConstraints([
        centerYConstraint,
        NSLayoutConstraint(item: matchButton.button, attribute: .centerX, relatedBy: .equal,
                           toItem: self.pearButton, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        ])
    }
    self.view.layoutIfNeeded()
    let verticalOffsetAmount: CGFloat = -70
    var totalVerticalOffset: CGFloat = -70
    for yConstraint in matchButtonYConstraints {
      yConstraint.constant = totalVerticalOffset
      totalVerticalOffset += verticalOffsetAmount
    }
    
    UIView.animate(withDuration: 0.7, delay: 0.0,
                   usingSpringWithDamping: 1.0, initialSpringVelocity: 20,
                   options: .curveEaseInOut,
                   animations: {
                    self.view.layoutIfNeeded()
    },
                   completion: nil)
    
  }
}
