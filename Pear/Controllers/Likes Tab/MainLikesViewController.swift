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
  }
  
  /// Setup should only be called once
  func setup() {
    
  }
  
  /// Stylize can be called more than once
  func stylize() {
    
  }
  
}
