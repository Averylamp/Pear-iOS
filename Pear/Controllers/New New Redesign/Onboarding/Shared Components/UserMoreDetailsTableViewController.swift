//
//  UserMoreDetailsTableViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserMoreDetailsTableViewController: UIViewController {

  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserMoreDetailsTableViewController? {
    guard let userMoreDetailsVC = R.storyboard.userMoreDetailsTableViewController()
      .instantiateInitialViewController() as? UserMoreDetailsTableViewController else {
        return nil
    }
    return userMoreDetailsVC
  }
  
}

// MARK: - Life Cycle
extension UserMoreDetailsTableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  func stylize() {
    
  }
  
  func setup() {
    
  }
  
}
