//
//  PromptInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class PromptInputViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  var friendFirstName: String!
  var friendGender: GenderEnum!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(friendFirstName: String, friendGender: GenderEnum) -> PromptInputViewController? {
    guard let promptInputVC = R.storyboard.onboardingFriendInfoViewController()
      .instantiateInitialViewController() as? PromptInputViewController else { return nil }
    promptInputVC.friendFirstName = friendFirstName
    promptInputVC.friendGender = friendGender
    return promptInputVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    
  }
  
}

// MARK: - Life Cycle
extension PromptInputViewController {
  
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
