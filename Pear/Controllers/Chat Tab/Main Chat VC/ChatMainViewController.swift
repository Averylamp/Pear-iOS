//
//  ChatMainViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics

extension Notification.Name {
  static let refreshChatsTab = Notification.Name("refreshChatsTab")
}

class ChatMainViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  private let currentChatsRefreshControl = UIRefreshControl()
//  private let requestsRefreshControl = UIRefreshControl()

//  var requestsTVC: ChatRequestsTableViewController?
  var matchesTVC: ChatRequestsTableViewController?
  private var messageRefreshTimer: Timer = Timer()

  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> ChatMainViewController? {
    let storyboard = UIStoryboard(name: String(describing: ChatMainViewController.self), bundle: nil)
    guard let chatMainVC = storyboard.instantiateInitialViewController() as? ChatMainViewController else { return nil }
    return chatMainVC
  }
  
  @IBAction func inboxButtonClicked(_ sender: Any) {
    Analytics.logEvent("CHAT_nav_TAP_inboxTab", parameters: nil)
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0,
                                               width: self.scrollView.frame.width, height: self.scrollView.frame.height), animated: true)
  }
  
  @IBAction func requestsButtonClicked(_ sender: Any) {
    Analytics.logEvent("CHAT_nav_TAP_requestsTab", parameters: nil)
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
//    self.scrollView.scrollRectToVisible(CGRect(x: self.scrollView.frame.width, y: 0,
//                                               width: self.scrollView.frame.width, height: self.scrollView.frame.height), animated: true)
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
                   selector: #selector(ChatMainViewController.reloadChatVCData),
                   name: .refreshChatsTab, object: nil)

    self.reloadChatVCData()

  }
  
  @objc func refreshControlChanged(sender: UIRefreshControl) {
    print("Refresh control changed")
    self.refreshMatchesObjects()
  }
  
  @objc func reloadChatVCData() {
    var iconNumber = 0

    if let matchesVC = self.matchesTVC {
      print("Updating currentMatchesTVC with :\(DataStore.shared.currentMatches.count) matches")
      matchesVC.updateMatches(matches: DataStore.shared.currentMatches)
      DataStore.shared.currentMatches.compactMap({$0.chat}).forEach({
        if let lastMessageTimestamp = $0.messages.last?.timestamp, $0.lastActivity.compare(lastMessageTimestamp) == .orderedDescending {
          iconNumber += 1
        }
      })
    }
    DispatchQueue.main.async {
      if iconNumber > 0 {
        self.tabBarItem.badgeValue = "\(iconNumber)"
      } else {
        self.tabBarItem.badgeValue = nil
      }
    }
  }
  
  func refreshMatchesObjects() {
    if let matchesVC = self.matchesTVC {
      DataStore.shared.refreshCurrentMatches { (currentMatches) in
        DispatchQueue.main.async {
          matchesVC.updateMatches(matches: currentMatches)
          self.currentChatsRefreshControl.endRefreshing()
        }
      }
    }
  }
  
  func setup() {
//    self.scrollView.delegate = self
    self.messageRefreshTimer = Timer.scheduledTimer(timeInterval: 15,
                                             target: self,
                                             selector: #selector(ChatMainViewController.reloadChatVCData),
                                             userInfo: nil,
                                             repeats: true)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.scrollView.layoutIfNeeded()
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.scrollView.frame.height)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.scrollView.frame.height)
  }
  
  func stylize() {
    if let refreshFont = R.font.openSansRegular(size: 14) {
    
      self.currentChatsRefreshControl
        .attributedTitle = NSAttributedString(string: "Refreshing Your Chats...",
                                              attributes: [NSAttributedString.Key.font: refreshFont,
                                                           NSAttributedString.Key.foregroundColor: UIColor(white: 0.7, alpha: 1.0)])
    }
  }
  
  func setupRequestTVCs() {
    self.currentChatsRefreshControl
      .addTarget(self,
                 action: #selector(ChatMainViewController.refreshControlChanged(sender:)),
                 for: .valueChanged)

    guard let matchesTVC = ChatRequestsTableViewController.instantiate(tableViewType: .inbox) else {
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
    
    self.view.layoutIfNeeded()
    matchesTVC.tableView.refreshControl = self.currentChatsRefreshControl
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.scrollView.frame.height)
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
      Analytics.logEvent("CHAT_inbox_EV_openedRequest", parameters: nil)
    }
  }
  
  func selectedProfile(user: PearUser) {
    DispatchQueue.main.async {
      HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
      let fullProfile = FullProfileDisplayData(user: user)
      guard let fullProfileScrollVC = FullProfileScrollViewController.instantiate(fullProfileData: fullProfile) else {
        print("failed to instantiate full profile scroll VC")
        return
      }
      self.navigationController?.pushViewController(fullProfileScrollVC, animated: true)
      Analytics.logEvent("CHAT_inbox_EV_openedInboxThread", parameters: nil)
    }
  }
  
}
