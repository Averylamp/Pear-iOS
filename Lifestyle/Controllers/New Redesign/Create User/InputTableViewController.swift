//
//  InputTableViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/22/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class InputTableViewController: UIViewController {

  var responseItems: [QuestionSuggestedResponse] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(questionResponseItems: [QuestionSuggestedResponse]) -> InputTableViewController? {
    guard let profileVibeVC = R.storyboard.profileInputVibeViewController()
      .instantiateInitialViewController() as? InputTableViewController else { return nil }
    profileVibeVC.profileData = profileCreationData
    return profileVibeVC
  }
  
}

// MARK: - Life Cycle
extension InputTableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.stylize()
  }
  
  func stylize() {
    
  }
  
  func setup() {
    
  }
  
}
