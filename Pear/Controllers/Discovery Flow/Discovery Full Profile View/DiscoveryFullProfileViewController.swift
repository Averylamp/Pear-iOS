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
import Firebase
import ContactsUI

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

protocol DiscoveryFullProfileDelegate: class {
  func decisionMade()
}

class DiscoveryFullProfileViewController: UIViewController {
  
  weak var delegate: DiscoveryFullProfileDelegate?
  var fullProfileData: FullProfileDisplayData!
  var profileID: String!
  var lastContentOffset: CGFloat = 0
  
  @IBOutlet weak var profileNameLabel: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pearButton: UIButton!
  @IBOutlet weak var likeButton: UIButton!
  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
  
  var lastTabBarVisible: Bool = true
  let requestAnimationTime: Double = 0.4
  var matchButtons: [MatchButton] = []
  var matchButtonShadows: [UIView] = []
  var fullPageBlocker: UIButton?
  var chatRequestVC: UIViewController?
  var chatRequestVCBottomConstraint: NSLayoutConstraint?
  var isSendingRequest = false
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(fullProfileData: FullProfileDisplayData!) -> DiscoveryFullProfileViewController? {
    let storyboard = UIStoryboard(name: String(describing: DiscoveryFullProfileViewController.self), bundle: nil)
    guard let fullDiscoveryVC = storyboard.instantiateInitialViewController() as? DiscoveryFullProfileViewController else { return nil }
    fullDiscoveryVC.fullProfileData = fullProfileData
    guard let matchingUserObject = fullProfileData.originObject as? PearUser else {
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
  
  @IBAction func skipProfileButtonClicked(_ sender: Any) {
   HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let userID = DataStore.shared.currentPearUser?.documentID,
      let discoveryItemID = self.fullProfileData.discoveryItemID else {
          print("Unable to get required information")
        return
    }
    #if PROD
    PearDiscoveryAPI.shared.skipDiscoveryItem(userID: userID,
                                              discoveryItemID: discoveryItemID) { (result) in
                                                switch result {
                                                case .success(let successful):
                                                  if successful {
                                                    print("Sucessfully skipped person")
                                                  } else {
                                                    print("Failed to skip person")
                                                  }
                                                case .failure(let error):
                                                  print("Error skipping person: \(error)")
                                                }
    }
    #endif
    if let delegate = self.delegate {
      self.fullProfileData.decisionMade = true
      delegate.decisionMade()
    }
  }
  
  @IBAction func personalRequestButtonClicked(_ sender: Any) {
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
      profileCount > 0 {
      self.displayPersonalRequestVC(personalUserID: personalUserID,
                                    thumbnailImageURL: requestedThumbnailURL,
                                    requestPersonName: self.fullProfileData.firstName ?? "")
    } else {
      self.promptProfileRequest()
    }
  }
  
  @objc func matchOptionClicked(sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
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
    
    guard let requestedThumbnailString = self.fullProfileData.imageContainers.first?.thumbnail.imageURL,
      let requestedThumbnailURL = URL(string: requestedThumbnailString) else {
        print("Failed to pull relavant discover user fields")
        return
    }
    guard let personalUserID = DataStore.shared.currentPearUser?.documentID else {
      print("Failed to get personal User ID")
      return
    }
    
    switch matchObject.type {
    case .placeholderEndorsed:
      self.promptEndorsedProfileCreation()
    case .personalUser:
      if matchObject.buttonEnabled {
        self.removeMatchButtons()
        self.displayPersonalRequestVC(personalUserID: personalUserID,
                                      thumbnailImageURL: requestedThumbnailURL,
                                      requestPersonName: self.fullProfileData.firstName ?? "")
      } else {
        if DataStore.shared.matchedUsersFromDefaults(userID: self.profileID).contains(personalUserID) {
          self.presentSimpleMessageAlert(title: "You have already Peared!",
                                         message: "If \(self.fullProfileData.firstName ?? "they") pears back you will be dropped into a chat",
                                         acceptAction: "Okay")
        } else if let userProfileCount = matchObject.user?.endorserIDs.count, userProfileCount > 0 {
          self.presentSimpleMessageAlert(title: "Preference mismatch",
                                         message: "Either \(self.fullProfileData.firstName ?? "this person") or You indicated preferences that are not compatible",
                                          acceptAction: "Okay")
        } else {
          self.promptProfileRequest()
        }
      }
    case .detachedProfile:
      if let firstName = matchObject.detachedProfile?.firstName {
        self.presentSimpleMessageAlert(title: "\(firstName) has not yet accepted their profile",
                                       message: "They must have approved their profile first",
                                       acceptAction: "Okay")
      } else {
        self.presentSimpleMessageAlert(title: "Your friend has not yet accepted their profile",
                                       message: "They must have approved their profile first",
                                       acceptAction: "Okay")
      }
    case .endorsedUser:
      guard let endorsedUserObject = matchObject.endorsedUser else {
        print("Failed to get endorsed User Object")
        return
      }
      if matchObject.buttonEnabled {
      guard  let endorsedUserThumbnailString = endorsedUserObject.displayedImages.first?.thumbnail.imageURL,
        let endorsedUserThumbnailURL = URL(string: endorsedUserThumbnailString) else {
          print("Failed to get required endorsed user fields")
          return
      }
      self.removeMatchButtons()
      self.displayEndorsedRequestVC(personalUserID: personalUserID,
                                    endorsedUserID: endorsedUserObject.documentID,
                                    thumbnailImageURL: requestedThumbnailURL,
                                    requestPersonName: self.fullProfileData.firstName ?? "",
                                    userPersonName: endorsedUserObject.firstName  ?? "",
                                    userPersonThumbnailURL: endorsedUserThumbnailURL)
      } else {
        if DataStore.shared.matchedUsersFromDefaults(userID: self.profileID).contains(endorsedUserObject.documentID) {
          self.presentSimpleMessageAlert(title: "You have already Peared \(self.fullProfileData.firstName  ?? "this person") and \(endorsedUserObject.firstName ?? "your friend")!",
            message: "If they both accept, they will be dropped into a chat",
            acceptAction: "Okay")
        } else {
          self.presentSimpleMessageAlert(title: "Preference mismatch",
            message: "Either \(self.fullProfileData.firstName ?? "this person") or \(endorsedUserObject.firstName ?? "your friend") indicated preferences that are not compatible",
            acceptAction: "Okay")
        }
      }
      
    }
    
  }
  
  @IBAction func filterButtonClicked(_ sender: Any) {
    print("filter button clicked")
    guard let filtersVC = DiscoveryFilterViewController.instantiate() else {
      print("Failed to create Filters VC")
      return
    }
    self.navigationController?.pushViewController(filtersVC, animated: true)
  }
  
}

// MARK: - Presentation Helpers
extension DiscoveryFullProfileViewController {
  
  func presentSimpleMessageAlert(title: String, message: String?, acceptAction: String) {
    let alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: .alert)
    let okayAction = UIAlertAction(title: acceptAction, style: .default, handler: nil)
    alertController.addAction(okayAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  func promptEndorsedProfileCreation() {
    let alertController = UIAlertController(title: "Match a Friend!",
                                            message: "Make a profile for a friend to pair them with \(self.fullProfileData.firstName!) or others.",
      preferredStyle: .alert)
    let createProfile = UIAlertAction(title: "Continue", style: .default) { (_) in
      DispatchQueue.main.async {
        self.promptContactsPicker()
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
        self.present(requestProfileVC, animated: true, completion: nil)
      }
    }
    
    let maybeLater = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(createProfile)
    alertController.addAction(maybeLater)
    self.present(alertController, animated: true, completion: nil)
  }
  
  @IBAction func pearButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    if !pearButton.isSelected {
      self.matchButtons = self.createMatchButtons()
      self.addMatchButtonsAnimated(matchButtons: self.matchButtons)
    } else {
      self.removeMatchButtons()
    }

  }
}

// MARK: - Life Cycle
extension DiscoveryFullProfileViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
    self.addFullStackVC()
    self.addKeyboardSizeNotifications()
  }
  
  func stylize() {
    self.scrollView.backgroundColor = R.color.cardBackgroundColor()
    self.profileNameLabel.stylizeSubtitleLabelSmall()
    self.profileNameLabel.text = self.fullProfileData.firstName
    if let firstName = self.fullProfileData.firstName,
      let age = self.fullProfileData.age {
      self.profileNameLabel.text = "\(firstName), \(age)"
    }
    
    self.pearButton.setImage(R.image.discoveryIconPearSelected(), for: .selected)
    self.stylizeActionButton(button: self.pearButton)
    self.stylizeActionButton(button: self.likeButton)
    self.stylizeActionButton(button: self.skipButton)
  }
  
  func setup() {
    self.scrollView.delegate = self
    if let visible = self.tabBarController?.tabBarIsVisible() {
      self.lastTabBarVisible = visible
    }
  }
  
  func stylizeActionButton(button: UIButton) {
    button.layer.cornerRadius = button.frame.height / 2.0
    button.layer.shadowOpacity = 0.2
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowRadius = 6
    button.layer.shadowOffset = CGSize(width: 2, height: 2)
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
        endorsedButton.setImage(R.image.friendsNoImage(), for: .normal)
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
        detachedProfileButton.setImage(R.image.friendsNoImage(), for: .normal)
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

extension DiscoveryFullProfileViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}

// MARK: - Keybaord Size Notifications
extension DiscoveryFullProfileViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(DiscoveryFullProfileViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(DiscoveryFullProfileViewController.keyboardWillHide(notification:)),
                   name: UIWindow.keyboardWillHideNotification,
                   object: nil)
  }
  
  @objc func keyboardWillChange(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
      let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let targetFrame = targetFrameNSValue.cgRectValue
      if let requestBottomConstraint = self.chatRequestVCBottomConstraint {
        requestBottomConstraint.constant = -(targetFrame.height - self.view.safeAreaInsets.bottom + 20)
        print("Constraint Value: \(requestBottomConstraint.constant)")
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

// MARK: ProfileCreationProtocol
extension DiscoveryFullProfileViewController: ProfileCreationProtocol, CNContactPickerDelegate {
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    self.didSelectContact(contact: contact)
  }
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
    self.didSelectContactProperty(contactProperty: contactProperty)
  }
  
  func receivedProfileCreationData(creationData: ProfileCreationData) {
    DispatchQueue.main.async {
      guard let vibesVC = ProfileInputVibeViewController.instantiate(profileCreationData: creationData) else {
        print("Failed to create Vibes VC")
        return
      }
      self.navigationController?.pushViewController(vibesVC, animated: true)
    }
  }
  
  func recievedProfileCreationError(title: String, message: String?) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(alert, animated: true)
    }
  }
  
  func promptContactsPicker() {
    let cnPicker = self.getContactsPicker()
    cnPicker.delegate = self
    self.present(cnPicker, animated: true, completion: nil)
  }
  
}

// MARK: - UIScrollViewDelegate
extension DiscoveryFullProfileViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if self.scrollView.contentOffset.y > self.lastContentOffset + 5.0 {
      if let tabBarVisible = self.tabBarController?.tabBarIsVisible(),
        tabBarVisible == self.lastTabBarVisible {
        self.tabBarController?.setTabBarVisible(visible: false, duration: 0.4, animated: true)
        self.lastTabBarVisible = false
      }
    } else if self.scrollView.contentOffset.y < self.lastContentOffset - 5.0 {
      if let tabBarVisible = self.tabBarController?.tabBarIsVisible(),
        tabBarVisible == self.lastTabBarVisible {
        self.tabBarController?.setTabBarVisible(visible: true, duration: 0.4, animated: true)
        self.lastTabBarVisible = true
      }
    }
    self.lastContentOffset = self.scrollView.contentOffset.y
    if scrollView.contentOffset.y > 50 {
      if headerHeightConstraint.constant != 50 {
        headerHeightConstraint.constant = 50
        UIView.animate(withDuration: 0.5) {
          self.view.layoutIfNeeded()
        }
      }
    } else {
      if headerHeightConstraint.constant != 0 {
        headerHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
          self.view.layoutIfNeeded()
        }
      }
    }
  }
  
}
