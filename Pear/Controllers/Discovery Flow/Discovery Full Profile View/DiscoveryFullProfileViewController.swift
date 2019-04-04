//
//  FullProfileScrollViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//
// swiftlint:disable file_length

import UIKit
import Sentry
import SDWebImage

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
  var endorsedUser: MatchingPearUser?
  var user: PearUser?
  var detachedProfile: PearDetachedProfile?
}

class DiscoveryFullProfileViewController: UIViewController {

  var fullProfileData: FullProfileDisplayData!
  var profileID: String!
  
  @IBOutlet weak var profileNameLabel: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pearButton: UIButton!
  
  let requestAnimationTime: Double = 0.4
  var matchButtons: [MatchButton] = []
  var matchButtonShadows: [UIView] = []
  var fullPageBlocker: UIButton?
  var chatRequestVC: UIViewController?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(fullProfileData: FullProfileDisplayData!) -> DiscoveryFullProfileViewController? {
    let storyboard = UIStoryboard(name: String(describing: DiscoveryFullProfileViewController.self), bundle: nil)
    guard let fullDiscoveryVC = storyboard.instantiateInitialViewController() as? DiscoveryFullProfileViewController else { return nil }
    fullDiscoveryVC.fullProfileData = fullProfileData
    guard let matchingUserObject = fullProfileData.originObject as? MatchingPearUser else {
      print("Failed to get matching user object from full profile")
      return nil
    }
    fullDiscoveryVC.profileID = matchingUserObject.documentID
    return fullDiscoveryVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func moreButtonClicked(_ sender: Any) {
    print("More Clicked")
    let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    let blockAction = UIAlertAction(title: "Block User", style: .destructive) { (_) in
      DispatchQueue.main.async {
        if let userID = self.fullProfileData.userID {
          var blockedUsers = DataStore.shared.fetchListFromDefaults(type: .blockedUsers)
          if !blockedUsers.contains(userID) {
            blockedUsers.append(userID)
            print(blockedUsers)
          }
          DataStore.shared.saveListToDefaults(list: blockedUsers, type: .blockedUsers)
          NotificationCenter.default.post(name: .refreshDiscoveryFeed, object: nil)
        }
        self.navigationController?.popViewController(animated: true)
        self.alert(title: "User Reported", message: "Thank you for your report and making Pear a safe place")
      }
    }
    let reportAction = UIAlertAction(title: "Report User", style: .destructive) { (_) in
      DispatchQueue.main.async {
        if let userID = self.fullProfileData.userID {
          let reportEvent = Event(level: .info)
          reportEvent.tags = ["reportedUserID": userID]
          reportEvent.message = "User Reported For Misconduct"
          reportEvent.extra = ["reportedUserID": userID]
          Client.shared?.send(event: reportEvent, completion: nil)
        }
        self.alert(title: "User Reported", message: "Thank you for your report and making Pear a safe place")
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    actionController.addAction(blockAction)
    actionController.addAction(reportAction)
    actionController.addAction(cancelAction)
    self.present(actionController, animated: true, completion: nil)
  }
  
  @objc func matchOptionClicked(sender: UIButton) {
    print("Match object clicked")
    var foundMatchObject: MatchButton?
    self.matchButtons.forEach({
      if $0.button == sender {
        foundMatchObject = $0
      }
    })
    guard let matchObject = foundMatchObject else {
      print("No Match Object Found")
      return
    }
    print(matchObject)
    
    guard let requestedThumbnailString = self.fullProfileData.imageContainers.first?.thumbnail.imageURL,
      let requestedThumbnailURL = URL(string: requestedThumbnailString) else {
        print("Failed to pull relavant discover user fields")
        return
    }
    
    switch matchObject.type {
    case .placeholderEndorsed:
      self.promptEndorsedProfileCreation()
    case .personalUser:
      if matchObject.buttonEnabled {
        guard let personalUserID = matchObject.user?.documentID else {
          print("Failed to get personal User ID")
          return
        }
        self.removeMatchButtons()
        self.displayPersonalRequestVC(personalUserID: personalUserID,
                                      thumbnailImageURL: requestedThumbnailURL,
                                      requestPersonName: self.fullProfileData.firstName)
      } else {
        self.promptProfileRequest()
      }
    case .detachedProfile:
      break
    case .endorsedUser:
      
      break
    }
    
  }
  
  func promptEndorsedProfileCreation() {
    let alertController = UIAlertController(title: "Match a Friend!",
                                            message: "Make a profile for a friend to pair them with \(self.fullProfileData.firstName!) or others.",
                                            preferredStyle: .alert)
    let createProfile = UIAlertAction(title: "Continue", style: .default) { (_) in
      DispatchQueue.main.async {
        guard let startFriendVC = GetStartedStartFriendProfileViewController.instantiate() else {
          print("Failed to create get started friend profile vc")
          return
        }
        self.navigationController?.setViewControllers([startFriendVC], animated: true)
      }
    }
    
    let maybeLater = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(createProfile)
    alertController.addAction(maybeLater)
    self.present(alertController, animated: true, completion: nil)
  }
  
  func promptProfileRequest() {
    let alertController = UIAlertController(title: "Match with yourself?",
                                            message: "To match this person with yourself, ask a friend to make you a profile first!",
                                            preferredStyle: .alert)
    let createProfile = UIAlertAction(title: "Ask a friend", style: .default) { (_) in
      DispatchQueue.main.async {
        guard let requestProfileVC = RequestProfileViewController.instantiate() else {
          print("Failed to create get started friend profile vc")
          return
        }
        self.navigationController?.setViewControllers([requestProfileVC], animated: true)
      }
    }
    
    let maybeLater = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(createProfile)
    alertController.addAction(maybeLater)
    self.present(alertController, animated: true, completion: nil)
  }
  
  @IBAction func pearButtonClicked(_ sender: Any) {
    if !pearButton.isSelected {
      self.matchButtons = self.createMatchButtons()
      self.addMatchButtonsAnimated(matchButtons: self.matchButtons)
    } else {
      self.removeMatchButtons()
    }
    return
    
    if DataStore.shared.remoteConfig.configValue(forKey: "pear_button_enabled").boolValue {
      if !pearButton.isSelected {
        self.matchButtons = self.createMatchButtons()
        self.addMatchButtonsAnimated(matchButtons: self.matchButtons)
      } else {
        self.removeMatchButtons()
      }
    } else {
      var pearMessage = "You'll be notified if someone pears you with them."
      if let configPearMessage = DataStore.shared.remoteConfig.configValue(forKey: "pear_button_string").stringValue {
        pearMessage = configPearMessage
      }
      let alertVC = UIAlertController(title: "Request Sent!", message: pearMessage, preferredStyle: .alert)
      let continueButton = UIAlertAction(title: "Okay!", style: .default, handler: nil)
      alertVC.addAction(continueButton)
      self.present(alertVC, animated: true, completion: nil)
    }
  }
}

// MARK: - Life Cycle
extension DiscoveryFullProfileViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.addFullStackVC()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  func stylize() {
    self.profileNameLabel.stylizeSubtitleLabelSmall()
    self.profileNameLabel.text = self.fullProfileData.firstName
    
    if DataStore.shared.remoteConfig.configValue(forKey: "pear_button_enabled").boolValue {
      self.pearButton.isHidden = false
    } else {
      self.pearButton.isHidden = false
//      self.pearButton.isHidden = true
    }
    self.pearButton.setImage(R.image.discoveryPearButtonSelected(), for: .selected)
    self.pearButton.layer.cornerRadius = 30
    self.pearButton.layer.shadowOpacity = 0.2
    self.pearButton.layer.shadowColor = UIColor.black.cgColor
    self.pearButton.layer.shadowRadius = 6
    self.pearButton.layer.shadowOffset = CGSize(width: 2, height: 2)
  }
  
  func addFullStackVC() {
    guard let fullProfileStackVC = FullProfileStackViewController.instantiate(userFullProfileData: self.fullProfileData) else {
        print("Failed to create full profiles stack VC")
        return
    }
    
    self.addChild(fullProfileStackVC)
    self.scrollView.addSubview(fullProfileStackVC.view)
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
}

// MARK: - Matching Helpers
extension DiscoveryFullProfileViewController {
  func compareMatchingSet(set1: (preferences: MatchingPreferences, demographics: MatchingDemographics),
                          set2: (preferences: MatchingPreferences, demographics: MatchingDemographics)) -> Bool {
    return set1.preferences.matchesDemographics(demographics: set2.demographics) &&
      set2.preferences.matchesDemographics(demographics: set1.demographics)
  }
  
  func getMatchingPrefDemoFromMatchButton(matchButton: MatchButton) -> (preferences: MatchingPreferences, demographics: MatchingDemographics)? {
    switch matchButton.type {
    case .detachedProfile:
      guard let detachedProfile = matchButton.detachedProfile else {
        return nil
      }
      return (detachedProfile.matchingPreferences, detachedProfile.matchingDemographics)
    case .endorsedUser:
      guard let endorsedProfile = matchButton.endorsedUser else {
        return nil
      }
      return (endorsedProfile.matchingPreferences, endorsedProfile.matchingDemographics)
    case .personalUser:
      guard let user = matchButton.user else {
        return nil
      }
      return (user.matchingPreferences, user.matchingDemographics)
    case .placeholderEndorsed:
      return nil
    }
  }
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
    guard let user = DataStore.shared.currentPearUser else {
      print("User not found")
      return []
    }
    let alreadyMatchedUsers = DataStore.shared.matchedUsersFromDefaults(userID: self.profileID)
    
    var allMatchButtons: [MatchButton] = []
    
    let youEnabled = user.userProfiles.count > 0 && !alreadyMatchedUsers.contains(user.documentID)
    let youButton = self.generateMatchButton(enabled: youEnabled)
    youButton.setImage(R.image.discoveryYouButton(), for: .normal)
    
    let youMatchButton = MatchButton(button: youButton,
                                     buttonEnabled: youEnabled,
                                     type: .personalUser,
                                     endorsedUser: nil,
                                     user: user,
                                     detachedProfile: nil)
    
    for endorsedProfile in DataStore.shared.endorsedUsers {
      let endorsedEnabled = !alreadyMatchedUsers.contains(endorsedProfile.documentID)
      let endorsedButton = self.generateMatchButton(enabled: endorsedEnabled)
      if let imageURLString = endorsedProfile.images.first?.thumbnail.imageURL,
        let imageURL = URL(string: imageURLString) {
        endorsedButton.sd_setImage(with: imageURL, for: .normal, completed: nil)
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
      }
      let endorsedMatchButton = MatchButton(button: detachedProfileButton,
                                            buttonEnabled: false,
                                            type: .detachedProfile,
                                            endorsedUser: nil,
                                            user: nil,
                                            detachedProfile: detachedProfile)
      allMatchButtons.append(endorsedMatchButton)
    }
    
    guard let discoveryUserPreferences = self.fullProfileData.matchingPreferences,
      let discoveryUserDemographics = self.fullProfileData.matchingDemographics else {
        print("Failed to get discovery user pref/demo")
        return []
    }
    
    let discoverySet = (preferences: discoveryUserPreferences, demographics: discoveryUserDemographics)
    
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
    
    allMatchButtons.insert(youMatchButton, at: 0)
    
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
    self.view.addConstraints([
      NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .centerX, relatedBy: .equal,
                         toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      centerYConstraint,
      NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .left, relatedBy: .greaterThanOrEqual,
                         toItem: self.view, attribute: .left, multiplier: 1.0, constant: 30.0),
      NSLayoutConstraint(item: personalRequestVC.view as Any, attribute: .right, relatedBy: .lessThanOrEqual,
                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: -30.0)
      ])
    personalRequestVC.didMove(toParent: self)
    self.view.layoutIfNeeded()
    centerYConstraint.constant = 0.0
    UIView.animate(withDuration: self.requestAnimationTime,
                   delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 5.0, options: .curveEaseOut,
                   animations: {
                    personalRequestVC.view.alpha = 1.0
                    self.view.layoutIfNeeded()
    }, completion: nil)    
    
  }
  
}

extension DiscoveryFullProfileViewController: PearModalDelegate {
  
  func createPearRequest(sentByUserID: String, sentForUserID: String) {
    PearMatchesAPI.shared.createMatchRequest(sentByUserID: sentByUserID,
                                             sentForUserID: sentForUserID,
                                             receivedByUserID: self.profileID,
                                             requestText: nil) { (result) in
      DispatchQueue.main.async {
        #if !DEVMODE
        DataStore.shared.addMatchedUserToDefaults(userID: self.profileID, matchedUserID: sentForUserID)
        #endif
        switch result {
        case .success(let success):
          if success {
            self.alert(title: "Successfully sent request!", message: "If they accept, a chat will be opened")
          } else {
            self.alert(title: "Failed to create request 😢", message: "The error has been reported and we are working to resolve it")
          }
        case .failure(let error):
          print("Error creating Request: \(error)")
          self.alert(title: "Failed to create request 😢", message: "Our servers had an oppsie woopsie")
        }
        self.dismissRequestModal()
      }
    }
  }
  
  func dismissPearRequest() {
    self.dismissRequestModal()
  }
  
}

extension DiscoveryFullProfileViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
