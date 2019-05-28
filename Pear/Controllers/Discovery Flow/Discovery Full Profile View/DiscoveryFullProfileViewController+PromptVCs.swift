//
//  DiscoveryFullProfileViewController+PromptVCs.swift
//  Pear
//
//  Created by Avery Lamp on 5/28/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAnalytics

// MARK: - Request View
extension DiscoveryFullProfileViewController {
  
  func deployFullPageBlocker() {
    if let blockingButton = self.fullPageBlocker {
      blockingButton.removeFromSuperview()
    }
    let blockingButton = UIButton()
    blockingButton.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
    blockingButton.translatesAutoresizingMaskIntoConstraints = false
    blockingButton.addTarget(self,
                             action: #selector(DiscoveryFullProfileViewController.fullPageBlockerClicked(sender:)),
                             for: .touchUpInside)
    self.view.addSubview(blockingButton)
    self.view.addConstraints([
      NSLayoutConstraint(item: blockingButton, attribute: .centerX, relatedBy: .equal,
                         toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: blockingButton, attribute: .centerY, relatedBy: .equal,
                         toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: blockingButton, attribute: .width, relatedBy: .equal,
                         toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: blockingButton, attribute: .height, relatedBy: .equal,
                         toItem: self.view, attribute: .height, multiplier: 1.0, constant: 0.0)
      ])
    self.fullPageBlocker = blockingButton
    blockingButton.alpha = 0.0
    UIView.animate(withDuration: self.requestAnimationTime) {
      blockingButton.alpha = 1.0
    }
  }
  
  @objc func fullPageBlockerClicked(sender: UIButton) {
    self.dismissRequestModal()
  }
  
  func dismissRequestModal() {
    UIView.animate(withDuration: self.requestAnimationTime, animations: {
      if let pageBlocker = self.fullPageBlocker {
        pageBlocker.alpha = 0.0
      }
      if let chatRequestVC = self.chatRequestVC {
        chatRequestVC.view.center.y -= 30
        chatRequestVC.view.alpha = 0.0
      }
    }, completion: { (_) in
      if let pageBlocker = self.fullPageBlocker {
        pageBlocker.removeFromSuperview()
        self.fullPageBlocker = nil
      }
      if let chatRequestVC = self.chatRequestVC {
        chatRequestVC.view.removeFromSuperview()
        chatRequestVC.removeFromParent()
        self.chatRequestVC = nil
      }
      if self.chatRequestVCBottomConstraint != nil {
        self.chatRequestVCBottomConstraint = nil
      }
    })
  }
  
  func displayPersonalRequestVC(personalUserID: String, thumbnailImageURL: URL, requestPersonName: String) {
    
    guard let personalRequestVC = ChatRequestPersonalViewController
      .instantiate(personalUserID: personalUserID,
                   thumbnailImageURL: thumbnailImageURL,
                   requestPersonName: requestPersonName) else {
                    print("Failed to create Personal Request VC")
                    return
    }
    self.chatRequestVC = personalRequestVC
    personalRequestVC.delegate = self
    self.deployFullPageBlocker()
    self.addChild(personalRequestVC)
    self.view.addSubview(personalRequestVC.view)
    personalRequestVC.view.translatesAutoresizingMaskIntoConstraints = false
    let centerYConstraint = NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .centerY, relatedBy: .equal,
                                               toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 40)
    centerYConstraint.priority = .defaultHigh
    let requestBottomConstraint = NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .bottom, relatedBy: .lessThanOrEqual,
                                                     toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -20)
    self.chatRequestVCBottomConstraint = requestBottomConstraint
    self.view.addConstraints([
      NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .centerX, relatedBy: .equal,
                         toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      centerYConstraint,
      requestBottomConstraint,
      NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .left, relatedBy: .equal,
                         toItem: self.view, attribute: .left, multiplier: 1.0, constant: 30.0),
      NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .right, relatedBy: .equal,
                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: -30.0)
      ])
    personalRequestVC.didMove(toParent: self)
    self.view.layoutIfNeeded()
    centerYConstraint.constant = 0.0
    Analytics.logEvent("tapped_send_personal_request", parameters: nil)
    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
      AnalyticsParameterItemID: self.fullProfileData.userID ?? "unknownID",
      AnalyticsParameterContentType: "profile",
      AnalyticsParameterMethod: "personal_request",
      "currentUserGender": DataStore.shared.currentPearUser?.gender?.toString() ?? "unknown" ])
    UIView.animate(withDuration: self.requestAnimationTime,
                   delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 5.0, options: .curveEaseOut,
                   animations: {
                    personalRequestVC.view.alpha = 1.0
                    self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  // swiftlint:disable:next function_parameter_count
  func displayEndorsedRequestVC(personalUserID: String,
                                endorsedUserID: String,
                                thumbnailImageURL: URL,
                                requestPersonName: String,
                                userPersonName: String,
                                userPersonThumbnailURL: URL) {
    
    guard let personalRequestVC = ChatRequestEndorsementViewController
      .instantiate(personalUserID: personalUserID,
                   endorsedUserID: endorsedUserID,
                   thumbnailImageURL: thumbnailImageURL,
                   requestPersonName: requestPersonName,
                   userPersonName: userPersonName,
                   userPersonThumbnailURL: userPersonThumbnailURL) else {
                    print("Failed to create Endorsed Request VC")
                    return
    }
    self.chatRequestVC = personalRequestVC
    personalRequestVC.delegate = self
    self.deployFullPageBlocker()
    self.addChild(personalRequestVC)
    self.view.addSubview(personalRequestVC.view)
    personalRequestVC.view.translatesAutoresizingMaskIntoConstraints = false
    let centerYConstraint = NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .centerY, relatedBy: .equal,
                                               toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 40)
    centerYConstraint.priority = .defaultHigh
    let requestBottomConstraint = NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .bottom, relatedBy: .lessThanOrEqual,
                                                     toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -20)
    self.chatRequestVCBottomConstraint = requestBottomConstraint
    self.view.addConstraints([
      NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .centerX, relatedBy: .equal,
                         toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      centerYConstraint,
      requestBottomConstraint,
      NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .left, relatedBy: .equal,
                         toItem: self.view, attribute: .left, multiplier: 1.0, constant: 30.0),
      NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .right, relatedBy: .equal,
                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: -30.0)
      ])
    personalRequestVC.didMove(toParent: self)
    self.view.layoutIfNeeded()
    centerYConstraint.constant = 0.0
    Analytics.logEvent("tapped_send_matchmaker_request", parameters: nil)
    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
      AnalyticsParameterItemID: self.fullProfileData.userID ?? "unknownID",
      AnalyticsParameterContentType: "profile",
      AnalyticsParameterMethod: "matchmaker_request",
      "currentUserGender": DataStore.shared.currentPearUser?.gender?.toString() ?? "unknown" ])
    UIView.animate(withDuration: self.requestAnimationTime,
                   delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 5.0, options: .curveEaseOut,
                   animations: {
                    personalRequestVC.view.alpha = 1.0
                    self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
}

extension DiscoveryFullProfileViewController: PearModalDelegate {
  
  func createPearRequest(sentByUserID: String, sentForUserID: String, requestText: String?) {
    guard !isSendingRequest else {
      print("Is already sending request")
      return
    }
    self.isSendingRequest = true
    PearMatchesAPI.shared.createMatchRequest(sentByUserID: sentByUserID,
                                             sentForUserID: sentForUserID,
                                             receivedByUserID: self.profileID,
                                             requestText: requestText) { (result) in
                                              DispatchQueue.main.async {
                                                DataStore.shared.addMatchedUserToDefaults(userID: self.profileID, matchedUserID: sentForUserID)
                                                switch result {
                                                case .success(let success):
                                                  if success {
                                                    self.alert(title: "Successfully sent request!", message: "If they accept, a chat will be opened")
                                                  } else {
                                                    self.alert(title: "Failed to create request 😢", message: "The error has been reported and we are working to resolve it")
                                                  }
                                                case .failure(let error):
                                                  print("Error creating Request: \(error)")
                                                  switch error {
                                                  case .graphQLError(let message ):
                                                    self.alert(title: "Failed to create request 😢", message: message)
                                                  default:
                                                    self.alert(title: "Failed to create request 😢", message: "Our servers had an oopsie woopsie")
                                                  }
                                                  
                                                }
                                                self.isSendingRequest = false
                                                self.dismissRequestModal()
                                                if let delegate = self.delegate {
                                                  self.fullProfileData.decisionMade = true
                                                  delegate.decisionMade()
                                                }
                                              }
    }
  }
  
  func dismissPearRequest() {
    self.dismissRequestModal()
  }
  
}