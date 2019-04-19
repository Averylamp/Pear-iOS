//
//  UserContactPermissionsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserContactPermissionsViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var numberProfilesLabel: UILabel!
  @IBOutlet weak var enableContactsButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserContactPermissionsViewController? {
    guard let contactPermissionsVC = R.storyboard.userContactPermissionsViewController()
      .instantiateInitialViewController() as? UserContactPermissionsViewController else { return nil }
    return contactPermissionsVC
  }

}

// MARK: - Life Cycle
extension UserContactPermissionsViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    self.view.backgroundColor = R.color.backgroundColorBlue()
    if let font = R.font.openSansExtraBold(size: 16) {
      self.titleLabel.font = font
    }
    
    self.titleLabel.textColor = UIColor.white
    if let font = R.font.openSansSemiBold(size: 16) {
      self.numberProfilesLabel.font = font
    }
    self.numberProfilesLabel.textColor = UIColor.white
    self.numberProfilesLabel.text = "No one has peared you yet 😢.  Pear a friend!"
    
    if let font = R.font.openSansBold(size: 18) {
      self.enableContactsButton.titleLabel?.font = font
    }
    self.enableContactsButton.setTitleColor(UIColor.black, for: .normal)
    self.enableContactsButton.backgroundColor = R.color.backgroundColorYellow()
    self.enableContactsButton.layer.cornerRadius = self.enableContactsButton.frame.height / 2.0
    
  }
  
}
