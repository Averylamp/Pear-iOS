//
//  FullProfileStackViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class FullProfileStackViewController: UIViewController {
  
  var userProfileData: GettingStartedUserProfileData!
  
  @IBOutlet var stackView: UIStackView!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedUserProfileData: GettingStartedUserProfileData) -> FullProfileStackViewController? {
    let storyboard = UIStoryboard(name: String(describing: FullProfileStackViewController.self), bundle: nil)
    guard let profileStackViewVC = storyboard.instantiateInitialViewController() as? FullProfileStackViewController else { return nil }
    profileStackViewVC.userProfileData = gettingStartedUserProfileData
    return profileStackViewVC
  }
  
}

// MARK: - Life Cycle
extension FullProfileStackViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    self.addDemographcsVC()
    self.addDemographcsVC()
    self.addDemographcsVC()
    self.addDemographcsVC()
    self.addDemographcsVC()
  }
  
  func addDemographcsVC() {
    guard let demographicsVC = ProfileDemographicsViewController.instantiate(firstName: userProfileData.firstName!,
                                                                             age: userProfileData.age!,
                                                                             gender: userProfileData.gender!) else {
      print("Failed to create Demographics VC")
      return
    }
    
    self.stackView.addArrangedSubview(demographicsVC.view)
    
  }

}
