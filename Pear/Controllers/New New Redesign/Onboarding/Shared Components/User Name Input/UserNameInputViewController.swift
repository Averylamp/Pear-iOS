//
//  UserNameInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserNameInputViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  
  @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserNameInputViewController? {
    guard let userNameVC = R.storyboard.userNameInputViewController()
      .instantiateInitialViewController() as? UserNameInputViewController else { return nil }
    return userNameVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.navigationController?.popViewController(animated: true)
  }
  
}

// MARK: - Life Cycle
extension UserNameInputViewController {
  
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
    self.addChild(firstNameInputVC)
    self.stackView.addSpacer(height: 10)
    self.stackView.addArrangedSubview(firstNameInputVC.view)
    firstNameInputVC.didMove(toParent: self)
    
    guard let lastNameInputVC = SimpleFieldInputViewController.instantiate(fieldName: "Last Name",
                                                                            previousValue: user.lastName,
                                                                            placeholder: "Enter your last name",
                                                                            visibility: false) else {
      print("Unable to instantiate Simple Field Input VC")
      return
    }
    self.addChild(lastNameInputVC)
    self.stackView.addSpacer(height: 10)
    self.stackView.addArrangedSubview(lastNameInputVC.view)
    lastNameInputVC.didMove(toParent: self)
  }
  
}

// MARK: - KeyboardEventsBottomProtocol
extension UserNameInputViewController: KeyboardEventsBottomProtocol {
  var bottomKeyboardConstraint: NSLayoutConstraint? {
    return self.scrollViewBottomConstraint
  }
  
  var bottomKeyboardPadding: CGFloat {
    return 0.0
  }
}

// MARK: - UIGestureRecognizerDelegate
extension UserNameInputViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
