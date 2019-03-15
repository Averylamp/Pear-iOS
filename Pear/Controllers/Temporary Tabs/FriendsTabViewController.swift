//
//  FriendsTabViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/15/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class FriendsTabViewController: UIViewController {
  
  class func instantiate() -> FriendsTabViewController? {
    let storyboard = UIStoryboard(name: String(describing: FriendsTabViewController.self), bundle: nil)
    guard let matchesVC = storyboard.instantiateInitialViewController() as? FriendsTabViewController else { return nil }
    return matchesVC
  }
}

// MARK: - Life Cycle
extension FriendsTabViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
