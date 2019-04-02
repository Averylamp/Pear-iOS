//
//  UpdateUserPreferencesViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/2/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UpdateUserPreferencesViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  
  weak var genderPreferencesVC: UserGenderPreferencesViewController?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UpdateUserPreferencesViewController? {
    let storyboard = UIStoryboard(name: String(describing: UpdateUserPreferencesViewController.self), bundle: nil)
    guard let updatePreferencesVC = storyboard.instantiateInitialViewController() as? UpdateUserPreferencesViewController else { return nil }
    
    return updatePreferencesVC
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    
  }
  
}

// MARK: - Life Cycle
extension UpdateUserPreferencesViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setupUserPreferences()
   }
  
  func stylize() {
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabel()
  }

  func setupUserPreferences() {
    guard let userGenderPreferencesVC = UserGenderPreferencesViewController.instantiate(genderPreferences: []) else {
      print("Unable to instantiate user gender preferences vc")
      return
    }
    stackView.addArrangedSubview(userGenderPreferencesVC.view)
    self.addChild(userGenderPreferencesVC)
    self.genderPreferencesVC = userGenderPreferencesVC
    userGenderPreferencesVC.didMove(toParent: self)
    
  }
  
}
