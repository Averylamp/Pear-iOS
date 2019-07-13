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
  
  static let requestHorizontalPadding = 20
  static let requestAnimationTime: Double = 0.4
  static let actionButtonSize: CGFloat = 60.0

  var fullProfileData: FullProfileDisplayData!
  var fullProfileStackVC: FullProfileStackViewController?
  var profileID: String!
  var isSendingRequest = false
  var lastTabBarVisible: Bool = true
  var otherUserThumbnailURL: URL?
  
  // Analytics variables
  var lastContentOffset: CGFloat = 0
  var exactLastContentOffset: CGFloat = 0
  var totalScrollDistance: CGFloat = 0
  var maxContentOffset: CGFloat = 0
  let initializationTime: Double = CACurrentMediaTime()

  // MARK: - IBOutlets
  @IBOutlet weak var profileNameLabel: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
  
  // MARK: - IBActions
  
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
        }
        self.alert(title: "User Blocked", message: "You won't see this user again")
        self.skipProfileButtonClicked(self.skipButton as Any)
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
        self.skipProfileButtonClicked(self.skipButton as Any)
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
    SlackHelper.shared.addEvent(text: "User Skipped profile: \(self.fullProfileData.firstName ?? "") (\(self.fullProfileData.age ?? 0)) \(self.fullProfileData.gender?.toString() ?? "Unknown Gender"), Images: \(self.fullProfileData.imageContainers.count), prompts: \(self.fullProfileData.questionResponses.count) \(self.slackHelperDetails())",
      color: UIColor.yellow)
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
  
//  @objc func matchOptionClicked(sender: UIButton) {
//    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
//    print("Match object clicked")
//    var foundMatchObject: MatchButton?
//    self.matchButtons.forEach({
//      if $0.button == sender {
//        foundMatchObject = $0
//      }
//    })
//    guard let matchObject = foundMatchObject else {
//      print("No Match Object Found")
//      return
//    }
//
//    guard let requestedThumbnailString = self.fullProfileData.imageContainers.first?.thumbnail.imageURL,
//      let requestedThumbnailURL = URL(string: requestedThumbnailString) else {
//        print("Failed to pull relavant discover user fields")
//        return
//    }
//    guard let personalUserID = DataStore.shared.currentPearUser?.documentID else {
//      print("Failed to get personal User ID")
//      return
//    }
//
//    switch matchObject.type {
//    case .placeholderEndorsed:
//      self.promptEndorsedProfileCreation()
//    case .personalUser:
//      if matchObject.buttonEnabled {
//        self.removeMatchButtons()
//      } else {
//        if DataStore.shared.matchedUsersFromDefaults(userID: self.profileID).contains(personalUserID) {
//          self.presentSimpleMessageAlert(title: "You have already Peared!",
//                                         message: "If \(self.fullProfileData.firstName ?? "they") pears back you will be dropped into a chat",
//                                         acceptAction: "Okay")
//        } else if let userProfileCount = matchObject.user?.endorserIDs.count, userProfileCount > 0 {
//          self.presentSimpleMessageAlert(title: "Preference mismatch",
//                                         message: "Either \(self.fullProfileData.firstName ?? "this person") or You indicated preferences that are not compatible",
//                                          acceptAction: "Okay")
//        } else {
//          self.promptProfileRequest()
//        }
//      }
//    case .detachedProfile:
//      if let firstName = matchObject.detachedProfile?.firstName {
//        self.presentSimpleMessageAlert(title: "\(firstName) has not yet accepted their profile",
//                                       message: "They must have approved their profile first",
//                                       acceptAction: "Okay")
//      } else {
//        self.presentSimpleMessageAlert(title: "Your friend has not yet accepted their profile",
//                                       message: "They must have approved their profile first",
//                                       acceptAction: "Okay")
//      }
//    case .endorsedUser:
//      guard let endorsedUserObject = matchObject.endorsedUser else {
//        print("Failed to get endorsed User Object")
//        return
//      }
//      if matchObject.buttonEnabled {
//      guard  let endorsedUserThumbnailString = endorsedUserObject.displayedImages.first?.thumbnail.imageURL,
//        let endorsedUserThumbnailURL = URL(string: endorsedUserThumbnailString) else {
//          print("Failed to get required endorsed user fields")
//          return
//      }
//      self.removeMatchButtons()
//      self.displayEndorsedRequestVC(personalUserID: personalUserID,
//                                    endorsedUserID: endorsedUserObject.documentID,
//                                    thumbnailImageURL: requestedThumbnailURL,
//                                    requestPersonName: self.fullProfileData.firstName ?? "",
//                                    userPersonName: endorsedUserObject.firstName  ?? "",
//                                    userPersonThumbnailURL: endorsedUserThumbnailURL)
//      } else {
//        if DataStore.shared.matchedUsersFromDefaults(userID: self.profileID).contains(endorsedUserObject.documentID) {
//        self.presentSimpleMessageAlert(title: "You have already Peared \(self.fullProfileData.firstName  ?? "this person") and \(endorsedUserObject.firstName ?? "your friend")!",
//            message: "If they both accept, they will be dropped into a chat",
//            acceptAction: "Okay")
//        } else {
//          self.presentSimpleMessageAlert(title: "Preference mismatch",
//          message: "Either \(self.fullProfileData.firstName ?? "this person") or \(endorsedUserObject.firstName ?? "your friend") indicated preferences that are not compatible",
//            acceptAction: "Okay")
//        }
//      }
//
//    }
//
//  }
  
}

// MARK: - Life Cycle
extension DiscoveryFullProfileViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
    self.addFullStackVC()
    self.caching()
  }

  func setup() {
    self.scrollView.delegate = self
    if let visible = self.tabBarController?.tabBarIsVisible() {
      self.lastTabBarVisible = visible
    }
  }
  
  func stylize() {
    self.scrollView.backgroundColor = R.color.cardBackgroundColor()
    self.profileNameLabel.stylizeSubtitleLabelSmall()
    self.profileNameLabel.text = self.fullProfileData.firstName
    if let firstName = self.fullProfileData.firstName,
      let age = self.fullProfileData.age {
      self.profileNameLabel.text = "\(firstName), \(age)"
    }
    self.stylizeActionButton(button: self.skipButton)
  }
  
  func stylizeActionButton(button: UIButton) {
    button.layer.cornerRadius = DiscoveryFullProfileViewController.actionButtonSize / 2.0
    button.layer.shadowOpacity = 0.2
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowRadius = 6
    button.layer.shadowOffset = CGSize(width: 2, height: 2)
  }
  
  func caching() {
    if let requestImageURLString = self.fullProfileData.imageContainers.first?.thumbnail.imageURL,
      let requestURL = URL(string: requestImageURLString) {
      self.otherUserThumbnailURL = requestURL
      SDWebImagePrefetcher.shared.prefetchURLs([requestURL])
    }
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
    self.fullProfileStackVC = fullProfileStackVC
  }
  
//  @objc func likeButtonClicked(sender: UIButton) {
//    print("like button clicked")
//    if sender.tag >= (self.fullProfileStackVC?.sectionItemsWithVCs.count ?? 0) {
//      print("couldnt get section item")
//      return
//    }
//    if let sectionItem = self.fullProfileStackVC?.sectionItemsWithVCs[sender.tag].sectionItem {
//      guard let requestedThumbnailString = self.fullProfileData.imageContainers.first?.thumbnail.imageURL,
//        let requestedThumbnailURL = URL(string: requestedThumbnailString) else {
//          print("Failed to pull relavant discover user fields")
//          return
//      }
//      guard let personalUserID = DataStore.shared.currentPearUser?.documentID else {
//        print("Failed to get personal User ID")
//        return
//      }
//      if let image = sectionItem.image, sectionItem.sectionType == .image {
//        print("liked image \(image.imageID)")
//        self.displayPersonalRequestVC(personalUserID: personalUserID,
//                                      thumbnailImageURL: requestedThumbnailURL,
//                                      requestPersonName: self.fullProfileData.firstName ?? "",
//                                      likedPhoto: image)
//
//      } else if let questionResponse = sectionItem.question, sectionItem.sectionType == .question {
//        print("liked questionResponse \(questionResponse.question.questionText)")
//        self.displayPersonalRequestVC(personalUserID: personalUserID,
//                                      thumbnailImageURL: requestedThumbnailURL,
//                                      requestPersonName: self.fullProfileData.firstName ?? "",
//                                      likedPhoto: nil,
//                                      likedPrompt: questionResponse)
//      }
//    }
//  }
}

// MARK: - UIGestureRecognizerDelegate
extension DiscoveryFullProfileViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}

// MARK: - UIScrollViewDelegate
extension DiscoveryFullProfileViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.totalScrollDistance += abs(self.scrollView.contentOffset.y - self.exactLastContentOffset)
    self.exactLastContentOffset = self.scrollView.contentOffset.y
    if self.scrollView.contentOffset.y > self.maxContentOffset {
      self.maxContentOffset = self.scrollView.contentOffset.y
    }
    self.updateTabBar(scrollContentOffset: self.scrollView.contentOffset.y)
    self.updateProfileNameHeader(scrollContentOffset: self.scrollView.contentOffset.y)
  }
  
  func updateTabBar(scrollContentOffset: CGFloat) {
    if scrollContentOffset > self.lastContentOffset + 5.0 {
      if let tabBarVisible = self.tabBarController?.tabBarIsVisible(),
        tabBarVisible == self.lastTabBarVisible {
        self.tabBarController?.setTabBarVisible(visible: false, duration: DiscoveryDecisionViewController.headerAnimationDuration, animated: true)
        self.lastTabBarVisible = false
      }
    } else if scrollContentOffset < self.lastContentOffset - 5.0 {
      if let tabBarVisible = self.tabBarController?.tabBarIsVisible(),
        tabBarVisible == self.lastTabBarVisible {
        self.tabBarController?.setTabBarVisible(visible: true, duration: DiscoveryDecisionViewController.headerAnimationDuration, animated: true)
        self.lastTabBarVisible = true
      }
    }
    self.lastContentOffset = self.scrollView.contentOffset.y
  }
  
  func updateProfileNameHeader(scrollContentOffset: CGFloat) {
    if scrollContentOffset > 50 {
      if headerHeightConstraint.constant != 50 {
        headerHeightConstraint.constant = 50
        NotificationCenter.default.post(name: .hideFiltersHeader, object: nil)
        UIView.animate(withDuration: DiscoveryDecisionViewController.headerAnimationDuration) {
          self.view.layoutIfNeeded()
        }
      }
    } else {
      if headerHeightConstraint.constant != 0 {
        NotificationCenter.default.post(name: .showFiltersHeader, object: nil)
        headerHeightConstraint.constant = 0
        UIView.animate(withDuration: DiscoveryDecisionViewController.headerAnimationDuration) {
          self.view.layoutIfNeeded()
        }
      }
    }
  }
  
}
