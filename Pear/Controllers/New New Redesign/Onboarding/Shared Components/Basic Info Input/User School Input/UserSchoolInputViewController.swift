//
//  UserSchoolInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserSchoolInputViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  
  @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
  
  var schoolNameVC: SimpleFieldInputViewController?
  var schoolYearVC: SimpleFieldInputViewController?
  
    /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserSchoolInputViewController? {
    guard let userSchoolVC = R.storyboard.userSchoolInputViewController()
      .instantiateInitialViewController() as? UserSchoolInputViewController else { return nil }
    return userSchoolVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.updateUser()
    self.navigationController?.popViewController(animated: true)
  }
  
  func updateUser() {
    let schoolName = self.schoolNameVC?.getNewFieldValue()
    let schoolYear = self.schoolYearVC?.getNewFieldValue()
    DataStore.shared.currentPearUser?.school = schoolName
    DataStore.shared.currentPearUser?.schoolYear  = schoolYear
    PearUpdateUserAPI.shared.updateUserSchool(schoolName: schoolName,
                                              schoolYear: schoolYear) { (result) in
                                                switch result {
                                                case .success(let successful):
                                                  if successful {
                                                    print("Successfully update user schoo")
                                                  } else {
                                                    print("Failed to update user schoo")
                                                  }
                                                case .failure(let error):
                                                  print("Failed to update user schoo: \(error)")
                                                }
    }
  }
  
}

// MARK: - Life Cycle
extension UserSchoolInputViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
    self.addKeyboardNotifications(animated: true)
    self.addKeyboardDismissOnTap()
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
    guard let schoolNameInputVC = SimpleFieldInputViewController.instantiate(fieldName: "School",
                                                                            previousValue: user.school,
                                                                            placeholder: "Enter your school's name",
                                                                            visibility: true) else {
                                                                              print("Unable to instantiate Simple Field Input VC")
                                                                              return
    }
    self.schoolNameVC = schoolNameInputVC
    self.addChild(schoolNameInputVC)
    self.stackView.addSpacer(height: 10)
    self.stackView.addArrangedSubview(schoolNameInputVC.view)
    schoolNameInputVC.didMove(toParent: self)
    
    guard let schoolYearInputVC = SimpleFieldInputViewController.instantiate(fieldName: "School Year",
                                                                           previousValue: user.schoolYear,
                                                                           placeholder: "Enter your school year",
                                                                           visibility: false) else {
                                                                            print("Unable to instantiate Simple Field Input VC")
                                                                            return
    }
    self.schoolYearVC = schoolYearInputVC
    self.addChild(schoolYearInputVC)
    self.stackView.addSpacer(height: 5)
    self.stackView.addArrangedSubview(schoolYearInputVC.view)
    schoolYearInputVC.didMove(toParent: self)
    schoolYearInputVC.inputTextField.keyboardType = .numberPad
    schoolYearInputVC.characterLimit = 4
  }
  
}

// MARK: - KeyboardEventsBottomProtocol
extension UserSchoolInputViewController: KeyboardEventsBottomProtocol {
  var bottomKeyboardConstraint: NSLayoutConstraint? {
    return self.scrollViewBottomConstraint
  }
  
  var bottomKeyboardPadding: CGFloat {
    return 0.0
  }
}

// MARK: - UIGestureRecognizerDelegate
extension UserSchoolInputViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}

// MARK: - KeyboardEventsDismissTapProtocol
extension UserSchoolInputViewController: KeyboardEventsDismissTapProtocol {
  func addKeyboardDismissOnTap() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserNameInputViewController.backgroundViewTapped)))
  }
  
  @objc func backgroundViewTapped() {
    self.dismissKeyboard()
  }
}
