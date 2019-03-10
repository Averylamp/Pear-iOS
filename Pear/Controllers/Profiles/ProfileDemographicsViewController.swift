//
//  ProfileDemographicsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfileDemographicsViewController: UIViewController {

  var userProfileData: GettingStartedUserProfileData!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedUserProfileData: GettingStartedUserProfileData) -> ProfileDemographicsViewController? {
    let storyboard = UIStoryboard(name: String(describing: FullProfileStackViewController.self), bundle: nil)
    guard let profileStackViewVC = storyboard.instantiateInitialViewController() as? ProfileDemographicsViewController else { return nil }
    profileStackViewVC.userProfileData = gettingStartedUserProfileData
    return profileStackViewVC
  }
  
}

// MARK: - Life Cycle
extension ProfileDemographicsViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
}
