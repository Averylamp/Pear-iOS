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
    self.addIncompleteProfileIfNeeded()
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
    }, completion: { (_) in
      self.fullPageBlocker.isUserInteractionEnabled = true
    })
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
    self.isSendingRequest = true
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

// MARK: - Incomplete Profile Banner
extension DiscoveryMatchmakerFullProfileViewController {
  
  func addIncompleteProfileIfNeeded() {
    if let numberPrompts = DataStore.shared.getCurrentFilterUser()?.questionResponses.count {
      if numberPrompts == 0 {
        self.addIncompleteProfileHeader(ctaText: "Your friend could use more prompts to complete their profile.  Help them out!")
      } else if numberPrompts < 3 {
        self.addIncompleteProfileHeader(ctaText: "Your friend could use more prompts to complete their profile.  Help them out!")
      }
    }
  }
  
  @objc func completeProfileBannerClicked(sender: UIButton) {
    SlackHelper.shared.addEvent(text: "Matchmaker Incomplete Profile Banner Clicked (no-op for now)", color: UIColor.green)
  }
  
  func addIncompleteProfileHeader(ctaText: String) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    let headerButton = UIButton()
    headerButton.addTarget(self,
                           action: #selector(DiscoveryMatchmakerFullProfileViewController.completeProfileBannerClicked(sender:)),
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
    headerCTASubtitleLabel.text = "ADD TO THEIR PROFILE"
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
