//
//  LikeFullProfileViewController.swift
//  Pear
//
//  Created by Avery Lamp on 6/26/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics

protocol LikeFullProfileDelegate: class {
  func decisionMade(accepted: Bool)
}

class LikeFullProfileViewController: UIViewController {
  
  weak var delegate: LikeFullProfileDelegate?
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var profileNameLabel: UILabel!
  @IBOutlet weak var rejectProfileButton: UIButton!
  @IBOutlet weak var acceptProfileButton: UIButton!
  
  var match: Match!
  var respondingToMatch: Bool = false
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(match: Match) -> LikeFullProfileViewController? {
    guard let likeFullProfileVC = R.storyboard.likeFullProfileViewController
      .instantiateInitialViewController() else { return nil }
    likeFullProfileVC.match = match
    return likeFullProfileVC
  }

  @IBAction func acceptRequestButton(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.respondToRequest(accepted: true)
    if let delegate = self.delegate {
      print("Delegate Decision Made")
      let isMatchmakerMade = match.sentByUser.documentID == match.sentForUser.documentID
      SlackHelper.shared.addEvent(text: "\(isMatchmakerMade ? "Matchmaker" : "Personal") Match Request Accepted!", color: UIColor.green)
      delegate.decisionMade(accepted: true)
    }
  }
  
  @IBAction func rejectRequestButton(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.respondToRequest(accepted: false)
    if let delegate = self.delegate {
      let isMatchmakerMade = match.sentByUser.documentID == match.sentForUser.documentID
      SlackHelper.shared.addEvent(text: "\(isMatchmakerMade ? "Matchmaker" : "Personal") Match Request Rejected!", color: UIColor.red)
      print("Delegate Decision Made")
      delegate.decisionMade(accepted: false)
    }
  }
  
  func respondToRequest(accepted: Bool) {
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Failed to get current User")
      return
    }
    guard !self.respondingToMatch else {
      return
    }
    self.respondingToMatch = true
    PearMatchesAPI.shared.decideOnMatchRequest(uid: userID,
                                               matchID: match.documentID,
                                               accepted: accepted) { (result) in
                                                self.respondingToMatch = false
                                                DataStore.shared.refreshCurrentMatches(matchesFound: { (_) in
                                                  NotificationCenter.default.post(name: .refreshChatsTab, object: nil)
                                                })
                                                switch result {
                                                case .success(let match):
                                                  self.match = match
                                                  if match.otherUserStatus == .accepted && match.currentUserStatus == .accepted {
                                                    let isMatchmakerMade = match.sentByUser.documentID == match.sentForUser.documentID
                                                    let matchmakerGender = match.sentByUser.gender?.toString() ?? "unknown"
                                                    Analytics.logEvent("new_chat_start", parameters: [
                                                      "currentUserGender": DataStore.shared.currentPearUser?.gender?.toString() ?? "unknown",
                                                      "isMatchmakerMade": isMatchmakerMade,
                                                      "matchmakerGender": isMatchmakerMade ? matchmakerGender : "na"
                                                      ])
                                                    DispatchQueue.main.async {
                                                      HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
                                                    }
                                                  } else {
                                                    DispatchQueue.main.async {
                                                      HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
                                                    }
                                                  }
                                                case .failure(let error):
                                                  DispatchQueue.main.async {
                                                    HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
                                                  }
                                                  print("Failed to respond to request: \(error)")
                                                }
    }
  }

}

// MARK: - Life Cycle
extension LikeFullProfileViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
    self.setupFullProfile()
  }
  
  /// Setup should only be called once
  func setup() {
    self.profileNameLabel.stylizeSubtitleLabelSmall()
    self.profileNameLabel.text = match.otherUser.firstName ?? ""
    
  }
  
  func generateRequestView() -> UIView? {
    guard let chat = self.match.chat else {
      print("Unable to get chat object")
      return nil
    }
    guard let matchRequestMessage = chat.messages.filter({ $0.type == .matchmakerRequest || $0.type == .personalRequest}).first else {
      print("Unable to find request message")
      return nil
    }
    switch matchRequestMessage.type {
    case .matchmakerRequest, .personalRequest:
      var matchmakerMessage = ""
      if matchRequestMessage.type == .matchmakerRequest {
        matchmakerMessage = "\(match.sentByUser.firstName ?? "Someone") peared you and \(match.otherUser.firstName ?? "their friend")"
      } else {
        matchmakerMessage = "\(match.sentByUser.firstName ?? "Someone") requested to match with you"
      }
      let containerView = UIView()
      containerView.translatesAutoresizingMaskIntoConstraints = false
      containerView.backgroundColor = R.color.cardBackgroundColor()
      let requestCardView = UIView()
      requestCardView.translatesAutoresizingMaskIntoConstraints = false
      requestCardView.layer.cornerRadius = 12
      requestCardView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
      containerView.addSubview(requestCardView)
      containerView.addConstraints([
        NSLayoutConstraint(item: requestCardView, attribute: .left, relatedBy: .equal,
                           toItem: containerView, attribute: .left, multiplier: 1.0, constant: 15.0),
        NSLayoutConstraint(item: requestCardView, attribute: .top, relatedBy: .equal,
                           toItem: containerView, attribute: .top, multiplier: 1.0, constant: 15.0),
        NSLayoutConstraint(item: requestCardView, attribute: .right, relatedBy: .equal,
                           toItem: containerView, attribute: .right, multiplier: 1.0, constant: -15.0),
        NSLayoutConstraint(item: requestCardView, attribute: .bottom, relatedBy: .equal,
                           toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -15.0)
        ])
      
      let requestMessageLabel = UILabel()
      requestMessageLabel.translatesAutoresizingMaskIntoConstraints = false
      if let font = R.font.openSansBold(size: 14) {
        requestMessageLabel.font = font
      }
      requestMessageLabel.textColor = R.color.primaryTextColor()
      requestMessageLabel.text = matchmakerMessage
      requestMessageLabel.numberOfLines = 0
      requestCardView.addSubview(requestMessageLabel)
      requestCardView.addConstraints([
        NSLayoutConstraint(item: requestMessageLabel, attribute: .left, relatedBy: .equal,
                           toItem: requestCardView, attribute: .left, multiplier: 1.0, constant: 15.0),
        NSLayoutConstraint(item: requestMessageLabel, attribute: .top, relatedBy: .equal,
                           toItem: requestCardView, attribute: .top, multiplier: 1.0, constant: 15.0),
        NSLayoutConstraint(item: requestMessageLabel, attribute: .right, relatedBy: .equal,
                           toItem: requestCardView, attribute: .right, multiplier: 1.0, constant: -15.0)
        ])
      if let matchmakerRequestMessage = matchRequestMessage.matchmakerMessage {
       let requestMatchmakerMessageLabel = UILabel()
        requestMatchmakerMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        if let font = R.font.openSansSemiBold(size: 14) {
          requestMatchmakerMessageLabel.font = font
        }
        requestMatchmakerMessageLabel.textColor = R.color.secondaryTextColor()
        requestMatchmakerMessageLabel.text = matchmakerRequestMessage
        requestMatchmakerMessageLabel.numberOfLines = 0
        requestCardView.addSubview(requestMatchmakerMessageLabel)
        requestCardView.addConstraints([
          NSLayoutConstraint(item: requestMatchmakerMessageLabel, attribute: .left, relatedBy: .equal,
                             toItem: requestMessageLabel, attribute: .left, multiplier: 1.0, constant: 0.0),
          NSLayoutConstraint(item: requestMatchmakerMessageLabel, attribute: .top, relatedBy: .equal,
                             toItem: requestMessageLabel, attribute: .bottom, multiplier: 1.0, constant: 8.0),
          NSLayoutConstraint(item: requestMatchmakerMessageLabel, attribute: .right, relatedBy: .equal,
                             toItem: requestMessageLabel, attribute: .right, multiplier: 1.0, constant: 0.0),
          NSLayoutConstraint(item: requestMatchmakerMessageLabel, attribute: .bottom, relatedBy: .equal,
                             toItem: requestCardView, attribute: .bottom, multiplier: 1.0, constant: -15.0)
          ])
        
      } else {
        requestCardView.addConstraints([
          NSLayoutConstraint(item: requestMessageLabel, attribute: .bottom, relatedBy: .equal,
                             toItem: requestCardView, attribute: .bottom, multiplier: 1.0, constant: -15.0)
          ])
      }
      return containerView
    default:
      break
      return nil
    }
    return nil
  }
  
  func setupFullProfile() {
    guard let fullProfileStackVC = FullProfileStackViewController.instantiate(userFullProfileData: FullProfileDisplayData(user: match.otherUser)) else {
      print("Failed to create full profiles stack VC")
      return
    }
    self.addChild(fullProfileStackVC)
    self.scrollView.addSubview(fullProfileStackVC.view)
    if let requestCardView = self.generateRequestView() {
      fullProfileStackVC.stackView.insertArrangedSubview(requestCardView, at: 0)
    }
    fullProfileStackVC.view.translatesAutoresizingMaskIntoConstraints = false
    
    self.scrollView.addConstraints([
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .centerX, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .width, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .top, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .bottom, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
      ])
    fullProfileStackVC.didMove(toParent: self)

  }
  
  /// Stylize can be called more than once
  func stylize() {
    self.stylizeActionButton(button: self.acceptProfileButton)
    self.stylizeActionButton(button: self.rejectProfileButton)
  }
  
  func stylizeActionButton(button: UIButton) {
    button.layer.cornerRadius = button.frame.height / 2.0
    button.layer.shadowOpacity = 0.2
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowRadius = 6
    button.layer.shadowOffset = CGSize(width: 2, height: 2)
  }
  
}
