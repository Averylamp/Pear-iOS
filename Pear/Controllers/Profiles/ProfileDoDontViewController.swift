//
//  ProfileDoDontViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfileDoDontViewController: UIViewController {
  
  var userProfileData: GettingStartedUserProfileData!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedUserProfileData: GettingStartedUserProfileData) -> ProfileDoDontViewController? {
    let storyboard = UIStoryboard(name: String(describing: ProfileDoDontViewController.self), bundle: nil)
    guard let profileStackViewVC = storyboard.instantiateInitialViewController() as? ProfileDoDontViewController else { return nil }
    profileStackViewVC.userProfileData = gettingStartedUserProfileData
    return profileStackViewVC
  }
  
}

// MARK: - Life Cycle
extension ProfileDoDontViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
}
