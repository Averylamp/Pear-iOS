//
//  UserAgePreferencesViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/2/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserAgePreferencesViewController: UIViewController {
  
  var minAge: Int = 18
  var maxAge: Int = 24
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(minAge: Int, maxAge: Int) -> UserAgePreferencesViewController? {
    let storyboard = UIStoryboard(name: String(describing: UserAgePreferencesViewController.self), bundle: nil)
    guard let agePrefVC = storyboard.instantiateInitialViewController() as? UserAgePreferencesViewController else { return nil }
    agePrefVC.minAge = minAge
    agePrefVC.maxAge = maxAge
    return agePrefVC
  }
  
}

// MARK: - Life Cycle
extension UserAgePreferencesViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    
  }
  
}
