//
//  ProfileInputBoastRoastViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfileInputBoastRoastViewController: UIViewController {
  
  var profileData: ProfileCreationData!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(profileCreationData: ProfileCreationData) -> ProfileInputBoastRoastViewController? {
    guard let profileRoastBoast = R.storyboard.profileInputBoastRoastViewController()
      .instantiateInitialViewController() as? ProfileInputBoastRoastViewController else { return nil }
    profileRoastBoast.profileData = profileCreationData
    return profileRoastBoast
  }

}

// MARK: - Life Cycle
extension ProfileInputBoastRoastViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
}
