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
  @IBOutlet weak var datePicker: UIDatePicker!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserAgeInputViewController? {
    guard let userNameVC = R.storyboard.userAgeInputViewController()
      .instantiateInitialViewController() as? UserAgeInputViewController else { return nil }
    return userNameVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.updateUser()
    self.navigationController?.popViewController(animated: true)
  }
  
  func updateUser() {
    DataStore.shared.currentPearUser?.birthdate = self.datePicker.date
    if let age = Calendar.init(identifier: .gregorian)
      .dateComponents([.year], from: self.datePicker.date, to: Date()).year {
        DataStore.shared.currentPearUser?.age = age
    }
    PearUpdateUserAPI.shared.updateUserAge(birthdate: self.datePicker.date) { (result) in
      switch result {
      case .success(let successful):
        if successful {
          print("Successfully update user birthdate/age")
        } else {
          print("Failed to update user birthdate/age")
        }
      case .failure(let error):
        print("Failed to update user birthdate/age: \(error)")
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
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  func stylize() {
    self.titleLabel.stylizeOnboardingHeaderTitleLabel()
    if let currentBirthday = DataStore.shared.currentPearUser?.birthdate {
      print(currentBirthday)
      self.datePicker.timeZone = TimeZone(secondsFromGMT: 0)
      self.datePicker.date = currentBirthday
    }
  }
  
  func setup() {
    self.datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
    self.datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -99, to: Date())
    self.datePicker.timeZone = TimeZone(secondsFromGMT: 0)
  }
  
}

// MARK: - UIGestureRecognizerDelegate
extension UserAgeInputViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
