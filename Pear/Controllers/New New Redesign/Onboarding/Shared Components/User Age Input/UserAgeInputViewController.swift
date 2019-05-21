//
//  UserNameInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserAgeInputViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  
  @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
  
  var firstNameVC: SimpleFieldInputViewController?
  var lastNameVC: SimpleFieldInputViewController?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserAgeInputViewController? {
    guard let userNameVC = R.storyboard.userNameInputViewController()
      .instantiateInitialViewController() as? UserAgeInputViewController else { return nil }
    return userNameVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.updateUser()
    self.navigationController?.popViewController(animated: true)
  }
  
  func updateUser() {
    let firstName = firstNameVC?.getNewFieldValue()
    let lastName = lastNameVC?.getNewFieldValue()
    DataStore.shared.currentPearUser?.firstName = firstName
    DataStore.shared.currentPearUser?.lastName  = lastName
    PearUpdateUserAPI.shared.updateUserName(firstName: firstName, lastName: lastName) { (result) in
      switch result {
      case .success(let successful):
        if successful {
          print("Successfully update user name")
        } else {
          print("Failed to update user name")
        }
      case .failure(let error):
        print("Failed to update user name: \(error)")
      }
    }
  }
  
}

// MARK: - Life Cycle
extension UserAgeInputViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
    self.addKeyboardNotifications(animated: true)
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  func stylize() {
    self.titleLabel.stylizeOnboardingHeaderTitleLabel()
  }
  
  func setup() {
        guard let user = DataStore.shared.currentPearUser else {
          print("Unable to get current user")
          return
        }
    guard let firstNameInputVC = SimpleFieldInputViewController.instantiate(fieldName: "First Name",
                                                                            previousValue: user.firstName,
                                                                            placeholder: "Enter your first name",
                                                                            visibility: true) else {
                                                                              print("Unable to instantiate Simple Field Input VC")
                                                                              return
    }
    self.firstNameVC = firstNameInputVC
    self.addChild(firstNameInputVC)
    self.stackView.addSpacer(height: 10)
    self.stackView.addArrangedSubview(firstNameInputVC.view)
    firstNameInputVC.didMove(toParent: self)
    firstNameInputVC.inputTextField.textContentType = .givenName
    firstNameInputVC.inputTextField.autocapitalizationType = .words
    guard let lastNameInputVC = SimpleFieldInputViewController.instantiate(fieldName: "Last Name",
                                                                            previousValue: user.lastName,
                                                                            placeholder: "Enter your last name",
                                                                            visibility: false) else {
      print("Unable to instantiate Simple Field Input VC")
      return
    }
    self.lastNameVC = lastNameInputVC
    self.addChild(lastNameInputVC)
    self.stackView.addSpacer(height: 5)
    self.stackView.addArrangedSubview(lastNameInputVC.view)
    lastNameInputVC.didMove(toParent: self)
    lastNameInputVC.inputTextField.textContentType = .familyName
    lastNameInputVC.inputTextField.autocapitalizationType = .words
  }
  
}

// MARK: - KeyboardEventsBottomProtocol
extension UserAgeInputViewController: KeyboardEventsBottomProtocol {
  var bottomKeyboardConstraint: NSLayoutConstraint? {
    return self.scrollViewBottomConstraint
  }
  
  var bottomKeyboardPadding: CGFloat {
    return 0.0
  }
}

// MARK: - UIGestureRecognizerDelegate
extension UserAgeInputViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
