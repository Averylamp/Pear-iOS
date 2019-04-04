//
//  ChatRequestPersonalViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/3/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ChatRequestPersonalViewController: UIViewController {
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(interests: [String]) -> ChatRequestPersonalViewController? {
    let storyboard = UIStoryboard(name: String(describing: ChatRequestPersonalViewController.self), bundle: nil)
    guard let profileInterestsVC = storyboard.instantiateInitialViewController() as? ChatRequestPersonalViewController else { return nil }
    return profileInterestsVC
  }
  
}

// MARK: - Life Cycle
extension ChatRequestPersonalViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
}
