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
  
  @IBOutlet weak var headerContainer: UIView!
  private let currentChatsRefreshControl = UIRefreshControl()
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
  
}

// MARK: - Life Cycle
extension ChatMainViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setup()
    self.stylize()
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
      print("Count \(DataStore.shared.currentMatches.compactMap({$0.chat}).compactMap({ $0.messages.last }).count)")
      DataStore.shared.currentMatches.compactMap({$0.chat}).forEach({
        if let lastMessageTimestamp = $0.messages.last?.timestamp,
          $0.lastOpenedDate.compare(lastMessageTimestamp) == .orderedAscending {
          print("Unread")
          iconNumber += 1
        }
      })
    }
    SlackHelper.shared.addEvent(uniquePrefix: "Matches Loaded: ", text: "\(DataStore.shared.currentMatches.count) matches found\nUnread Messages: \(iconNumber)", color: iconNumber > 0 ? UIColor.green : UIColor.orange)
    DispatchQueue.main.async {
      if iconNumber > 0 {
        self.tabBarItem.badgeValue = "\(iconNumber)"
      } else {
        self.tabBarItem.badgeValue = nil
      }
      NotificationCenter.default.post(name: .updateAppIconNumber, object: nil)
    }
  }
  
  func refreshMatchesObjects() {
    if let matchesVC = self.matchesTVC {
      DataStore.shared.refreshCurrentMatches { (_) in
        DispatchQueue.main.async {
          self.reloadChatVCData()
          self.currentChatsRefreshControl.endRefreshing()
        }
      }
    }
  }
  
  func setup() {
    self.messageRefreshTimer = Timer.scheduledTimer(timeInterval: 30,
                                             target: self,
                                             selector: #selector(ChatMainViewController.reloadChatVCData),
                                             userInfo: nil,
                                             repeats: true)
    self.setupRequestTVCs()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
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
    self.view.addSubview(matchesTVC.view)
    matchesTVC.view.translatesAutoresizingMaskIntoConstraints = false
    self.view.addConstraints([
      NSLayoutConstraint(item: matchesTVC.view as Any, attribute: .left, relatedBy: .equal,
                         toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: matchesTVC.view as Any, attribute: .right, relatedBy: .equal,
                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: matchesTVC.view as Any, attribute: .top, relatedBy: .equal,
                         toItem: self.headerContainer, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: matchesTVC.view as Any, attribute: .bottom, relatedBy: .equal,
                         toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
      ])
    matchesTVC.didMove(toParent: self)
    matchesTVC.updateMatches(matches: DataStore.shared.currentMatches)
    
    self.view.layoutIfNeeded()
    matchesTVC.tableView.refreshControl = self.currentChatsRefreshControl
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
