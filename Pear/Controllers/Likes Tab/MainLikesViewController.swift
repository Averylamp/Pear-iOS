//
//  MainLikesViewController.swift
//  Pear
//
//  Created by Avery Lamp on 6/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

extension Notification.Name {
  static let refreshLikesTab = Notification.Name("refreshLikesTab")
}

class MainLikesViewController: UIViewController {

  @IBOutlet weak var scrollView: UIScrollView!
  var requestsTVC: ChatRequestsTableViewController?
  private var messageRefreshTimer: Timer = Timer()
  private let requestsRefreshControl = UIRefreshControl()

  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> MainLikesViewController? {
    guard let mainLikesVC = R.storyboard.mainLikesViewController
      .instantiateInitialViewController() else { return nil }
    return mainLikesVC
  }

}

// MARK: - Life Cycle
extension MainLikesViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
    self.refreshRequests()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.scrollView.layoutIfNeeded()
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.scrollView.frame.height)
  }
  
  /// Setup should only be called once
  func setup() {
    guard let requestsTVC = ChatRequestsTableViewController.instantiate(tableViewType: .requests) else {
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
                         toItem: self.scrollView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: requestsTVC.view as Any, attribute: .centerY, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
      ])
    requestsTVC.didMove(toParent: self)
    requestsTVC.updateMatches(matches: DataStore.shared.matchRequests)
    self.view.layoutIfNeeded()
    requestsTVC.tableView.refreshControl = self.requestsRefreshControl
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.scrollView.frame.height)
  }
  
  /// Stylize can be called more than once
  func stylize() {
    
  }

  func refreshRequests() {
    if let requestVC = self.requestsTVC {
      DataStore.shared.refreshMatchRequests { (matchRequests) in
        DispatchQueue.main.async {
          print("Updating with \(matchRequests.count) match requests")
          requestVC.updateMatches(matches: matchRequests)
          self.requestsRefreshControl.endRefreshing()
        }
      }
    }
  }
}
// MARK: - ChatTVDelegate
extension MainLikesViewController: ChatRequestTableViewControllerDelegate {
  
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
  
  func selectedProfile(user: PearUser) {
    DispatchQueue.main.async {
      HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
      let fullProfile = FullProfileDisplayData(user: user)
      guard let fullProfileScrollVC = FullProfileScrollViewController.instantiate(fullProfileData: fullProfile) else {
        print("failed to instantiate full profile scroll VC")
        return
      }
      self.navigationController?.pushViewController(fullProfileScrollVC, animated: true)
    }
  }
  
}
