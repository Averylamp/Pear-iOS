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

//// MARK: - Request View
//extension DiscoveryFullProfileViewController {
//
//  func deployFullPageBlocker() {
//    if let blockingButton = self.fullPageBlocker {
//      blockingButton.removeFromSuperview()
//    }
//    let blockingButton = UIButton()
//    blockingButton.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
//    blockingButton.translatesAutoresizingMaskIntoConstraints = false
//    blockingButton.addTarget(self,
//                             action: #selector(DiscoveryFullProfileViewController.fullPageBlockerClicked(sender:)),
//                             for: .touchUpInside)
//    self.view.addSubview(blockingButton)
//    self.view.addConstraints([
//      NSLayoutConstraint(item: blockingButton, attribute: .centerX, relatedBy: .equal,
//                         toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
//      NSLayoutConstraint(item: blockingButton, attribute: .centerY, relatedBy: .equal,
//                         toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
//      NSLayoutConstraint(item: blockingButton, attribute: .width, relatedBy: .equal,
//                         toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0),
//      NSLayoutConstraint(item: blockingButton, attribute: .height, relatedBy: .equal,
//                         toItem: self.view, attribute: .height, multiplier: 1.0, constant: 0.0)
//      ])
//    self.fullPageBlocker = blockingButton
//    blockingButton.alpha = 0.0
//    UIView.animate(withDuration: self.requestAnimationTime) {
//      blockingButton.alpha = 1.0
//    }
//  }
//
//  @objc func fullPageBlockerClicked(sender: UIButton) {
//    self.dismissRequestModal()
//  }
//
//  func dismissRequestModal() {
//    UIView.animate(withDuration: self.requestAnimationTime, animations: {
//      if let pageBlocker = self.fullPageBlocker {
//        pageBlocker.alpha = 0.0
//      }
//      if let chatRequestVC = self.chatRequestVC {
//        chatRequestVC.view.center.y -= 30
//        chatRequestVC.view.alpha = 0.0
//      }
//    }, completion: { (_) in
//      if let pageBlocker = self.fullPageBlocker {
//        pageBlocker.removeFromSuperview()
//        self.fullPageBlocker = nil
//      }
//      if let chatRequestVC = self.chatRequestVC {
//        chatRequestVC.view.removeFromSuperview()
//        chatRequestVC.removeFromParent()
//        self.chatRequestVC = nil
//      }
//      if self.chatRequestVCBottomConstraint != nil {
//        self.chatRequestVCBottomConstraint = nil
//      }
//    })
//  }
//
//  func displayPersonalRequestVC(personalUserID: String,
//                                thumbnailImageURL: URL,
//                                requestPersonName: String,
//                                likedPhoto: ImageContainer? = nil,
//                                likedPrompt: QuestionResponseItem? = nil) {
//
//    guard let personalRequestVC = PersonalLikeViewController
//      .instantiate(personalUserID: personalUserID,
//                   thumbnailImageURL: thumbnailImageURL,
//                   requestPersonName: requestPersonName,
//                   likedPhoto: likedPhoto,
//                   likedPrompt: likedPrompt) else {
//                    print("Failed to create Personal Request VC")
//                    return
//    }
//    self.chatRequestVC = personalRequestVC
//    personalRequestVC.delegate = self
//    self.deployFullPageBlocker()
//    self.addChild(personalRequestVC)
//    self.view.addSubview(personalRequestVC.view)
//    personalRequestVC.view.translatesAutoresizingMaskIntoConstraints = false
//    let centerYConstraint = NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .centerY, relatedBy: .equal,
//                                               toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 40)
//    centerYConstraint.priority = UILayoutPriority(120)
//    let requestBottomConstraint = NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .bottom, relatedBy: .lessThanOrEqual,
//                                                     toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -20)
//    self.chatRequestVCBottomConstraint = requestBottomConstraint
//    self.view.addConstraints([
//      NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .centerX, relatedBy: .equal,
//                         toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
//      centerYConstraint,
//      requestBottomConstraint,
//      NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .left, relatedBy: .equal,
//                         toItem: self.view, attribute: .left, multiplier: 1.0, constant: 20.0),
//      NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .right, relatedBy: .equal,
//                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: -20.0)
//      ])
//    personalRequestVC.didMove(toParent: self)
//    self.view.layoutIfNeeded()
//    centerYConstraint.constant = 0.0
//    Analytics.logEvent("tapped_send_personal_request", parameters: nil)
//    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
//      AnalyticsParameterItemID: self.fullProfileData.userID ?? "unknownID",
//      AnalyticsParameterContentType: "profile",
//      AnalyticsParameterMethod: "personal_request",
//      "currentUserGender": DataStore.shared.currentPearUser?.gender?.toString() ?? "unknown" ])
//    UIView.animate(withDuration: self.requestAnimationTime,
//                   delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 5.0, options: .curveEaseOut,
//                   animations: {
//                    personalRequestVC.view.alpha = 1.0
//                    self.view.layoutIfNeeded()
//    }, completion: nil)
//  }
//
//  // swiftlint:disable:next function_parameter_count
//  func displayEndorsedRequestVC(personalUserID: String,
//                                endorsedUserID: String,
//                                thumbnailImageURL: URL,
//                                requestPersonName: String,
//                                userPersonName: String,
//                                userPersonThumbnailURL: URL) {
//
//    guard let personalRequestVC = ChatRequestEndorsementViewController
//      .instantiate(personalUserID: personalUserID,
//                   endorsedUserID: endorsedUserID,
//                   thumbnailImageURL: thumbnailImageURL,
//                   requestPersonName: requestPersonName,
//                   userPersonName: userPersonName,
//                   userPersonThumbnailURL: userPersonThumbnailURL) else {
//                    print("Failed to create Endorsed Request VC")
//                    return
//    }
//    self.chatRequestVC = personalRequestVC
//    personalRequestVC.delegate = self
//    self.deployFullPageBlocker()
//    self.addChild(personalRequestVC)
//    self.view.addSubview(personalRequestVC.view)
//    personalRequestVC.view.translatesAutoresizingMaskIntoConstraints = false
//    let centerYConstraint = NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .centerY, relatedBy: .equal,
//                                               toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 40)
//    centerYConstraint.priority = .defaultHigh
//    let requestBottomConstraint = NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .bottom, relatedBy: .lessThanOrEqual,
//                                                     toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -20)
//    self.chatRequestVCBottomConstraint = requestBottomConstraint
//    self.view.addConstraints([
//      NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .centerX, relatedBy: .equal,
//                         toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
//      centerYConstraint,
//      requestBottomConstraint,
//      NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .left, relatedBy: .equal,
//                         toItem: self.view, attribute: .left, multiplier: 1.0, constant: 30.0),
//      NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .right, relatedBy: .equal,
//                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: -30.0)
//      ])
//    personalRequestVC.didMove(toParent: self)
//    self.view.layoutIfNeeded()
//    centerYConstraint.constant = 0.0
//    Analytics.logEvent("tapped_send_matchmaker_request", parameters: nil)
//    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
//      AnalyticsParameterItemID: self.fullProfileData.userID ?? "unknownID",
//      AnalyticsParameterContentType: "profile",
//      AnalyticsParameterMethod: "matchmaker_request",
//      "currentUserGender": DataStore.shared.currentPearUser?.gender?.toString() ?? "unknown" ])
//    UIView.animate(withDuration: self.requestAnimationTime,
//                   delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 5.0, options: .curveEaseOut,
//                   animations: {
//                    personalRequestVC.view.alpha = 1.0
//                    self.view.layoutIfNeeded()
//    }, completion: nil)
//  }
//
//}
//
//extension DiscoveryFullProfileViewController: PearModalDelegate {
//
//  func createPearRequest(sentByUserID: String, sentForUserID: String, requestText: String?, likedPhoto: ImageContainer?, likedPrompt: QuestionResponseItem?) {
//    guard !isSendingRequest else {
//      print("Is already sending request")
//      return
//    }
//    self.dismissRequestModal()
//    if let delegate = self.delegate {
//      self.fullProfileData.decisionMade = true
//      delegate.decisionMade()
//    }
//    let matchCreationData = MatchRequestCreationData(sentByUserID: sentByUserID,
//                                                     sentForUserID: sentForUserID,
//                                                     receivedByUserID: self.profileID,
//                                                     likedPhoto: likedPhoto,
//                                                     likedPrompt: likedPrompt)
//    PearMatchesAPI.shared.createMatchRequest(matchCreationData: matchCreationData) { (result) in
//                                              DispatchQueue.main.async {
// swiftlint:disable:next line_length
//                                                SlackHelper.shared.addEvent(text: "User Sent \(sentByUserID == sentForUserID ? "Personal" : "Matchmaker") Request. to profile: \(self.fullProfileData.firstName ?? "") (\(self.fullProfileData.age ?? 0)) \(self.fullProfileData.gender?.toString() ?? "Unknown Gender"), Images: \(self.fullProfileData.imageContainers.count), prompts: \(self.fullProfileData.questionResponses.count)\(requestText != nil ? "\nRequest Text: \(requestText!)" : "")) \(self.slackHelperDetails())",
//                                                  color: UIColor.green)
//                                                DataStore.shared.addMatchedUserToDefaults(userID: self.profileID, matchedUserID: sentForUserID)
//                                                switch result {
//                                                case .success:
//                                                  break
//                                                case .failure(let error):
//                                                  print("Error creating Request: \(error)")
//                                                  SentryHelper.generateSentryEvent(message: "Failed to send match request from:\(sentByUserID) for:\(sentForUserID) to:\(self.profileID!)")
//                                                  switch error {
//                                                  case .graphQLError(let message ):
//                                                    break
////                                                    self.alert(title: "Failed to create request 😢", message: message)
//                                                  default:
//                                                    break
////                                                    self.alert(title: "Failed to create request 😢", message: "Our servers had an oopsie woopsie")
//                                                  }
//
//                                                }
//
//                                              }
//    }
//  }
//
//  func dismissPearRequest() {
//    self.dismissRequestModal()
//  }
//
//}
