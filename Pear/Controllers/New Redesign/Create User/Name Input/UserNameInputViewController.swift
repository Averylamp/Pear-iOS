//
//  UserNameInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserNameInputViewController: UIViewController {
  
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var nameTextField: UITextField!
  
  var profileData: ProfileCreationData!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(profileCreationData: ProfileCreationData) -> UserNameInputViewController? {
    guard let userNameVC = R.storyboard.userNameInputViewController()
      .instantiateInitialViewController() as? UserNameInputViewController else { return nil }
    userNameVC.profileData = profileCreationData
    return userNameVC
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    if let name = self.nameTextField.text, name.count > 2 {
      guard let userID = DataStore.shared.currentPearUser?.documentID else {
        print("No documentID Found")
        return
      }
      self.profileData.updateAuthor(authorID: userID, authorFirstName: name)
    }
  }
  
    
}


// MARK: - Life Cycle
extension UserNameInputViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize(){
    self.view.backgroundColor = R.color.backgroundColorOrange()
    if let font = R.font.openSansExtraBold(size: 16) {
      self.titleLabel.font = font
    }
    self.titleLabel.textColor = UIColor.white
    self.continueButton.layer.cornerRadius = self.continueButton.frame.height / 2.0
    self.continueButton.setTitleColor(UIColor.black, for: .normal)
    self.continueButton.backgroundColor = R.color.backgroundColorYellow()
  }
  
}

// MARK: - Dismiss First Responder on Click
extension UserNameInputViewController {
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserNameInputViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.view.endEditing(true)
  }
}

