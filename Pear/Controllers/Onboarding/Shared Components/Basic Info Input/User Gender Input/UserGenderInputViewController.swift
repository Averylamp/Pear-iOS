//
//  UserGenderInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserGenderInputViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet var genderButtons: [UIButton]!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserGenderInputViewController? {
    guard let genderInputVC = R.storyboard.userGenderInputViewController
      .instantiateInitialViewController()  else { return nil }
    return genderInputVC
  }

  @IBAction func backButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.updateUser()
    self.navigationController?.popViewController(animated: true)
  }
  
  func updateUser() {
    if let selectedButton = self.genderButtons.filter({ $0.isSelected }).first {
      var updatedGender: GenderEnum = .male
      switch selectedButton.tag {
      case 0:
        updatedGender = .female
      case 1:
        updatedGender = .male
      case 2:
        updatedGender = .nonbinary
      default:
        print("Unknown button selected")
        return
      }
      if DataStore.shared.currentPearUser?.gender != updatedGender {
        DataStore.shared.currentPearUser?.gender = updatedGender
        PearUpdateUserAPI.shared.updateUserGender(gender: updatedGender) { (result) in
          switch result {
          case .success(let successful):
            if successful {
              print("Successfully update user gender")
            } else {
              print("Failed to update user gender")
            }
          case .failure(let error):
            print("Failed to update user gender: \(error)")
          }
        }
      }
    }
  }
  
  @IBAction func genderButtonClicked(_ sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.genderButtons.forEach({ $0.isSelected = false})
    sender.isSelected = true
    self.genderButtons.forEach({
      if $0.isSelected {
        $0.backgroundColor = R.color.primaryBrandColor()
      } else {
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
      }
    })
  }
  
}

// MARK: - Life Cycle
extension UserGenderInputViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
//    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  func stylize() {
    self.genderButtons.forEach({
      $0.setTitleColor(R.color.primaryTextColor(), for: .normal)
      $0.setTitleColor(UIColor.white, for: .selected)
      $0.layer.cornerRadius = $0.frame.height / 2.0
      $0.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
      if let font = R.font.openSansBold(size: 14.0) {
        $0.titleLabel?.font = font
      }
    })
    if let gender = DataStore.shared.currentPearUser?.gender {
      switch gender {
      case .female:
        if let femaleButton = self.genderButtons.filter({ $0.tag == 0}).first {
          self.genderButtonClicked(femaleButton)
        }
      case .male:
        if let maleButton = self.genderButtons.filter({ $0.tag == 1}).first {
          self.genderButtonClicked(maleButton)
        }
      case .nonbinary:
        if let nonbinaryButton = self.genderButtons.filter({ $0.tag == 2}).first {
          self.genderButtonClicked(nonbinaryButton)
        }
      }
    }
  }
  
  func setup() {
    
  }
  
}

// MARK: - UIGestureRecognizerDelegate
extension UserGenderInputViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
