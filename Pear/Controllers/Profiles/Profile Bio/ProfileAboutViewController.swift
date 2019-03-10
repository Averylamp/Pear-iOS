//
//  ProfileAboutViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/13/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfileAboutViewController: UIViewController {
  
  var aboutBio: String!
  @IBOutlet weak var bioLabel: UILabel!
  
  var profileBioHeightConstraint: NSLayoutConstraint?
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(aboutBio: String) -> ProfileAboutViewController? {
    let storyboard = UIStoryboard(name: String(describing: ProfileAboutViewController.self), bundle: nil)
    guard let profileAboutVC = storyboard.instantiateInitialViewController() as? ProfileAboutViewController else { return nil }
    profileAboutVC.aboutBio = aboutBio
    return profileAboutVC
  }
  
}

// MARK: - Life Cycle
extension ProfileAboutViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.bioLabel.text = aboutBio
  }
  
  func setHeightConstraint(constraint: NSLayoutConstraint) {
    self.profileBioHeightConstraint = constraint
    self.view.layoutIfNeeded()
    constraint.constant = self.bioLabel.frame.origin.y + self.bioLabel.frame.height + 12
  }
}
