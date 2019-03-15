//
//  FriendsTabViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/15/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class FriendsTabViewController: UIViewController {
  
  @IBOutlet weak var createFriendProfileButton: UIButton!
  
  class func instantiate() -> FriendsTabViewController? {
    let storyboard = UIStoryboard(name: String(describing: FriendsTabViewController.self), bundle: nil)
    guard let matchesVC = storyboard.instantiateInitialViewController() as? FriendsTabViewController else { return nil }
    return matchesVC
  }
  
  @IBAction func createFriendProfileButtonClicked(_ sender: Any) {
    guard let startFriendVC = GetStartedStartFriendProfileViewController.instantiate() else {
      print("Failed to create get started friend profile vc")
      return
    }
    self.navigationController?.setViewControllers([startFriendVC], animated: true)
  }
  
}

// MARK: - Life Cycle
extension FriendsTabViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    self.createFriendProfileButton.stylizeDark()
    
  }
  
}
