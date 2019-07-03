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
    print("Main Likes VC Loaded")
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
    
  }
  
  /// Stylize can be called more than once
  func stylize() {
    
  }

  func refreshRequests() {
    DataStore.shared.refreshMatchRequests { (matchRequests) in
      DispatchQueue.main.async {
        print("Updating with \(matchRequests.count) match requests")
        if matchRequests.count > 0 {
          self.tabBarItem.badgeValue = "\(matchRequests.count)"
        } else {
          self.tabBarItem.badgeValue = nil
        }
        self.requestsRefreshControl.endRefreshing()
      }
    }
  }
  
}
