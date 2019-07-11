//
//  DiscoveryMatchmakerFullProfileViewController.swift
//  Pear
//
//  Created by Avery Lamp on 7/7/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAnalytics

protocol MatchmakerRequestDelegate: class {
  func dismissPearRequest()
  func createPearRequest(requestText: String?)
}

class DiscoveryMatchmakerFullProfileViewController: DiscoveryFullProfileViewController {
  
  var fullPageBlocker =  UIButton()
  var chatRequestVC: UIViewController?
  var chatRequestVCBottomConstraint: NSLayoutConstraint?
  let pearButton = UIButton()
  var matchmakingForID: String!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(fullProfileData: FullProfileDisplayData, matchmakingForID: String) -> DiscoveryMatchmakerFullProfileViewController? {
    guard let fullDiscoveryVC = R.storyboard.discoveryMatchmakerFullProfileViewController
      .instantiateInitialViewController() else { return nil }
    fullDiscoveryVC.fullProfileData = fullProfileData
    fullDiscoveryVC.matchmakingForID = matchmakingForID
    guard let matchingUserObject = fullProfileData.originObject as? PearUser else {
      print("Failed to get matching user object from full profile")
      return nil
    }
    fullDiscoveryVC.profileID = matchingUserObject.documentID
    return fullDiscoveryVC
  }
  
  @objc func pearButtonClicked(sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let endorsedUser = DataStore.shared.getCurrentFilterUser() else {
      print("Unable to find endorsed user")
      return
    }
    self.displayEndorsedRequestVC(endorsedUser: endorsedUser,
                                  otherUserName: self.fullProfileData.firstName ?? "No Name",
                                  otherUserThumbnailURL: self.otherUserThumbnailURL)
  }
  
}

// MARK: - Life Cycle
extension DiscoveryMatchmakerFullProfileViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupMatchmakerVC()
    self.stylizeMatchmakerVC()
    self.addKeyboardSizeNotifications()
  }
  
  /// Setup should only be called once
  func setupMatchmakerVC() {
    self.view.addSubview(pearButton)
    self.pearButton.translatesAutoresizingMaskIntoConstraints = false
    self.pearButton.addTarget(self,
                              action: #selector(DiscoveryMatchmakerFullProfileViewController.pearButtonClicked(sender:)),
                              for: .touchUpInside)
    self.pearButton.contentMode = .scaleAspectFit
    self.pearButton.setImage(R.image.discoveryIconPear(), for: .normal)
    self.pearButton.setImage(R.image.discoveryIconPearSelected(), for: .selected)
    self.stylizeActionButton(button: self.pearButton)
    self.view.addConstraints([
      NSLayoutConstraint(item: self.pearButton, attribute: .centerY, relatedBy: .equal,
                         toItem: self.skipButton, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.pearButton, attribute: .width, relatedBy: .equal,
                         toItem: self.skipButton, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.pearButton, attribute: .height, relatedBy: .equal,
                         toItem: self.skipButton, attribute: .height, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.pearButton, attribute: .right, relatedBy: .equal,
                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: -15.0)
      ])
    
    self.fullPageBlocker.backgroundColor = UIColor(white: 0.0, alpha: 0.15)
    self.fullPageBlocker.addTarget(self,
                                   action: #selector(DiscoveryMatchmakerFullProfileViewController.dismissPearRequest),
                                   for: .touchUpInside)
    self.fullPageBlocker.translatesAutoresizingMaskIntoConstraints = false
    self.fullPageBlocker.alpha = 0.0
    self.fullPageBlocker.isUserInteractionEnabled = false
    self.view.addSubview(self.fullPageBlocker)
    self.view.addConstraints([
        NSLayoutConstraint(item: self.fullPageBlocker, attribute: .centerX, relatedBy: .equal,
                           toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: self.fullPageBlocker, attribute: .centerY, relatedBy: .equal,
                           toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: self.fullPageBlocker, attribute: .width, relatedBy: .equal,
                           toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: self.fullPageBlocker, attribute: .height, relatedBy: .equal,
                           toItem: self.view, attribute: .height, multiplier: 1.0, constant: 0.0)
      ])
  }
  
  /// Stylize can be called more than once
  func stylizeMatchmakerVC() {
    
  }
  
}

// MARK: - Prompt Request VC
extension DiscoveryMatchmakerFullProfileViewController {
  
  func deployFullPageBlocker() {
    UIView.animate(withDuration: 0.3, animations: {
      self.fullPageBlocker.alpha = 1.0
    }) { (_) in
      self.fullPageBlocker.isUserInteractionEnabled = true
    }
  }
  
  func displayEndorsedRequestVC(endorsedUser: PearUser,
                                otherUserName: String,
                                otherUserThumbnailURL: URL?) {
    guard self.chatRequestVC == nil else {
      print("Already deployed VC")
      return
    }
    guard let personalRequestVC = ChatRequestEndorsementViewController
      .instantiate(endorsedUser: endorsedUser,
                   otherUserName: otherUserName,
                   otherUserThumbnailURL: otherUserThumbnailURL) else {
                    print("Failed to create Endorsed Request VC")
                    return
    }
    self.deployFullPageBlocker()
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
    UIView.animate(withDuration: DiscoveryFullProfileViewController.requestAnimationTime,
                   delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 5.0, options: .curveEaseOut,
                   animations: {
                    personalRequestVC.view.alpha = 1.0
                    self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
}

// MARK: - Matchmaker Request Delegate
extension DiscoveryMatchmakerFullProfileViewController: MatchmakerRequestDelegate {
  
  @objc func dismissPearRequest() {
    self.dismissFullPageBlocker()
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.4, animations: {
        self.chatRequestVC?.view.alpha = 0.0
      }, completion: { (_) in
        self.chatRequestVC?.view.removeFromSuperview()
        self.chatRequestVC?.removeFromParent()
        self.chatRequestVC = nil
        self.chatRequestVCBottomConstraint = nil
      })
      
    }
  }
  
  func dismissFullPageBlocker() {
    self.fullPageBlocker.isUserInteractionEnabled = false
    UIView.animate(withDuration: 0.3, animations: {
      self.fullPageBlocker.alpha = 0.0
    })
  }
  
  func createPearRequest(requestText: String?) {
    guard let sentByID = DataStore.shared.currentPearUser?.documentID else {
      print("Failed to get current user")
      return
    }
    guard !isSendingRequest else {
      print("Is already sending request")
      return
    }
    self.dismissPearRequest()
    if let delegate = self.delegate {
      self.fullProfileData.decisionMade = true
      delegate.decisionMade()
    }
    SlackHelper.shared.addEvent(text: "User Sent Matchmaker Request. to profile: \(self.fullProfileData.slackHelperSummary()), Request Text \(requestText ?? "") \(self.slackHelperDetails())", color: UIColor.green)
    let matchCreationData = MatchRequestCreationData(sentByUserID: sentByID,
                                                     sentForUserID: self.matchmakingForID,
                                                     receivedByUserID: self.profileID,
                                                     requestText: requestText,
                                                     likedPhoto: nil,
                                                     likedPrompt: nil)
    PearMatchesAPI.shared.createMatchRequest(matchCreationData: matchCreationData) { (result) in
      switch result {
      case .success:
        break
      case .failure(let error):
        print("Error creating Request: \(error)")
        SentryHelper.generateSentryEvent(message: "Failed to send match request from:\(sentByID) for:\(self.matchmakingForID) to:\(self.profileID!)")
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

// MARK: - Keybaord Size Notifications
extension DiscoveryMatchmakerFullProfileViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(DiscoveryMatchmakerFullProfileViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(DiscoveryMatchmakerFullProfileViewController.keyboardWillHide(notification:)),
                   name: UIWindow.keyboardWillHideNotification,
                   object: nil)
  }
  
  @objc func keyboardWillChange(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
      let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let targetFrame = targetFrameNSValue.cgRectValue
      if let requestBottomConstraint = self.chatRequestVCBottomConstraint {
        requestBottomConstraint.constant = -(targetFrame.height - self.view.safeAreaInsets.bottom + 20)
      }
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  @objc func keyboardWillHide(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      if let requestBottomConstraint = self.chatRequestVCBottomConstraint {
        requestBottomConstraint.constant =  20
      }
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
}
