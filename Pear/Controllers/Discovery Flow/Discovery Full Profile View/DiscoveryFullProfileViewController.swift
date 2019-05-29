//
//  FullProfileScrollViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Sentry
import SDWebImage
import Firebase

protocol DiscoveryFullProfileDelegate: class {
  func decisionMade()
  func scannedUser(fullProfileDisplay: FullProfileDisplayData)
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
  
  @IBAction func qrScannerButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.presentScanner()
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
