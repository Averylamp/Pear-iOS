//
//  ProfileInputVibeViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfileInputVibeViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  
  var profileData: ProfileCreationData!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(profileCreationData: ProfileCreationData) -> ProfileInputVibeViewController? {
    guard let profileVibeVC = R.storyboard.profileInputVibeViewController()
      .instantiateInitialViewController() as? ProfileInputVibeViewController else { return nil }
    profileVibeVC.profileData = profileCreationData
    return profileVibeVC
  }
  
}

// MARK: - Life Cycle
extension ProfileInputVibeViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func stylize() {
    self.view.backgroundColor = R.color.backgroundColorOrange()
    if let font = R.font.openSansExtraBold(size: 16) {
      self.titleLabel.font = font
    }
    self.titleLabel.textColor = UIColor.white

  }
  
}
