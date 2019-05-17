//
//  UserBasicInfoViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserBasicInfoTableViewController: UIViewController {

  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserBasicInfoTableViewController? {
    guard let userBasicInfoVC = R.storyboard.userBasicInfoTableViewController()
      .instantiateInitialViewController() as? UserBasicInfoTableViewController else {
        return nil
    }
    return userBasicInfoVC
  }
  
}

// MARK: - Life Cycle
extension UserBasicInfoTableViewController {
  
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
