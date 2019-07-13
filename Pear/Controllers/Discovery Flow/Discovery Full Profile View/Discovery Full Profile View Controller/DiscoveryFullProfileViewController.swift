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
