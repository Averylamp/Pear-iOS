//
//  ChatMainViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

extension Notification.Name {
  static let refreshChatsTab = Notification.Name("refreshChatsTab")
}

class ChatMainViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var inboxButton: UIButton!
  @IBOutlet weak var requestsButton: UIButton!
  
  var requestsTVC: ChatRequestsTableViewController?
  var matchesTVC: ChatRequestsTableViewController?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> ChatMainViewController? {
    let storyboard = UIStoryboard(name: String(describing: ChatMainViewController.self), bundle: nil)
    guard let chatMainVC = storyboard.instantiateInitialViewController() as? ChatMainViewController else { return nil }
    return chatMainVC
  }
  
  @IBAction func inboxButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0,
                                               width: self.scrollView.frame.width, height: self.scrollView.frame.height), animated: true)
  }
  
  @IBAction func requestsButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.scrollView.scrollRectToVisible(CGRect(x: self.scrollView.frame.width, y: 0,
                                               width: self.scrollView.frame.width, height: self.scrollView.frame.height), animated: true)
  }
  
}

// MARK: - Life Cycle
extension ChatMainViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setup()
    self.stylize()
    self.setupRequestTVCs()
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(ChatMainViewController.reloadChatVCs),
                   name: .refreshChatsTab, object: nil)

  }
  
  @objc func reloadChatVCs() {
    if let requestVC = self.requestsTVC {
      requestVC.updateMatches(matches: DataStore.shared.matchRequests)
    }
    if let matchesVC = self.matchesTVC {
      matchesVC.updateMatches(matches: DataStore.shared.currentMatches)
    }
  }
  
  func setup() {
    self.scrollView.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.scrollView.layoutIfNeeded()
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * 2, height: self.scrollView.frame.height)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * 2, height: self.scrollView.frame.height)
  }
  
  func stylize() {
    self.scrollView.isPagingEnabled = true
    if let buttonFont = R.font.nunitoSemiBold(size: 18) {
      self.inboxButton.titleLabel?.font = buttonFont
      self.requestsButton.titleLabel?.font = buttonFont
    }
    self.inboxButton.setBackgroundImage(nil, for: .selected)
    self.inboxButton.setTitleColor(R.color.secondaryTextColor(), for: .normal)
    self.inboxButton.setTitleColor(R.color.primaryTextColor(), for: .selected)
    self.inboxButton.isSelected = true
    self.requestsButton.setTitleColor(R.color.secondaryTextColor(), for: .normal)
    self.requestsButton.setTitleColor(R.color.primaryTextColor(), for: .selected)
  }
  
  func setupRequestTVCs() {
    guard let matchesTVC = ChatRequestsTableViewController.instantiate() else {
      print("Failed to instantiate matches TVC")
      return
    }
    self.matchesTVC = matchesTVC
    matchesTVC.delegate = self
    self.addChild(matchesTVC)
    self.scrollView.addSubview(matchesTVC.view)
    matchesTVC.view.translatesAutoresizingMaskIntoConstraints = false
    self.scrollView.addConstraints([
      NSLayoutConstraint(item: matchesTVC.view as Any, attribute: .width, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: matchesTVC.view as Any, attribute: .height, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .height, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: matchesTVC.view as Any, attribute: .centerX, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: matchesTVC.view as Any, attribute: .centerY, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
      ])
    matchesTVC.didMove(toParent: self)
    matchesTVC.updateMatches(matches: DataStore.shared.currentMatches)
    
    guard let requestsTVC = ChatRequestsTableViewController.instantiate() else {
      print("Failed to instantiate requests TVC")
      return
    }
    self.requestsTVC = requestsTVC
    requestsTVC.delegate = self
    self.addChild(requestsTVC)
    self.scrollView.addSubview(requestsTVC.view)
    requestsTVC.view.translatesAutoresizingMaskIntoConstraints = false
    self.scrollView.addConstraints([
      NSLayoutConstraint(item: requestsTVC.view as Any, attribute: .width, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: requestsTVC.view as Any, attribute: .height, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .height, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: requestsTVC.view as Any, attribute: .centerX, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .centerX, multiplier: 3.0, constant: 0.0),
      NSLayoutConstraint(item: requestsTVC.view as Any, attribute: .centerY, relatedBy: .equal,
                       toItem: self.scrollView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
      ])
    requestsTVC.didMove(toParent: self)
    requestsTVC.updateMatches(matches: DataStore.shared.matchRequests)
    
    self.view.layoutIfNeeded()
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * 2, height: self.scrollView.frame.height)
  }
  
}

// MARK: - UIScrollViewDelegate
extension ChatMainViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
    if pageIndex == 0 {
      self.inboxButton.isSelected = true
      self.requestsButton.isSelected = false
    } else {
      self.inboxButton.isSelected = false
      self.requestsButton.isSelected = true
    }
  }
  
}

// MARK: - ChatTVDelegate
extension ChatMainViewController: ChatRequestTableViewControllerDelegate {
  
  func selectedMatch(match: Match) {
    guard let chat = match.chat else {
      print("Failed to get chat for match")
      return
    }
    
    DispatchQueue.main.async {
      HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
      guard let fullChatVC = FullChatViewController.instantiate(match: match, chat: chat) else {
        print("Failed to instantiate full chat VC")
        return
      }
      self.navigationController?.pushViewController(fullChatVC, animated: true)      
    }
  }
  
  func selectedProfile(user: MatchingPearUser) {
    DispatchQueue.main.async {
      HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
      let fullProfile = FullProfileDisplayData(matchingUser: user)
      guard let fullProfileScrollVC = FullProfileScrollViewController.instantiate(fullProfileData: fullProfile) else {
        print("failed to instantiate full profile scroll VC")
        return
      }
      self.navigationController?.pushViewController(fullProfileScrollVC, animated: true)
    }
  }
  
}
