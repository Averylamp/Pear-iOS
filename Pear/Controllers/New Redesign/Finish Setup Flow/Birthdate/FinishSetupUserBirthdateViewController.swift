//
//  FinishSetupUserBirthdateViewController.swift
//  Pear
//
//  Created by Brian Gu on 4/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class FinishSetupUserBirthdateViewController: UIViewController {
  
  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  @IBOutlet weak var nextButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> FinishSetupUserBirthdateViewController? {
    let storyboard = UIStoryboard(name: String(describing: FinishSetupUserBirthdateViewController.self), bundle: nil)
    guard let userBirthdateVC = storyboard.instantiateInitialViewController() as? FinishSetupUserBirthdateViewController else { return nil }
    return userBirthdateVC
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    print("next button clicked")
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    let birthdate = self.datePicker.date
    let age = Calendar.current.dateComponents([.year], from: self.datePicker.date, to: Date()).year!
    if age >= 18 {
      guard let userID = DataStore.shared.currentPearUser?.documentID else {
        print("Failed to get Current User")
        return
      }
      self.nextButton.isEnabled = false
      self.nextButton.alpha = 0.3
      PearUserAPI.shared.updateUserBirthdateAge(userID: userID, age: age, birthdate: birthdate) { (result) in
        switch result {
        case .success(let successful):
          if successful {
            print("Update user birthdate and age was successful")
          } else {
            print("Update user birthdate and age was unsuccessful")
          }
          DispatchQueue.main.async {
            guard let photosVC = FinishSetupUserPhotosViewController.instantiate(displayedImages: [], imageBank: []) else {
              print("Failed to initialize photos VC")
              return
            }
            self.navigationController?.pushViewController(photosVC, animated: true)
          }

        case .failure(let error):
          print("Update user failure: \(error)")
        }
        DispatchQueue.main.async {
          self.nextButton.isEnabled = true
          self.nextButton.alpha = 1.0
        }
      }
    }
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
}

// MARK: - Life Cycle
extension FinishSetupUserBirthdateViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
    datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -99, to: Date())
    self.stylize()
  }
  
  func stylize() {
    self.nextButton.stylizeChatAccept()
  }
  
}
