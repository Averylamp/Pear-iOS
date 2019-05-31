//
//  UserEthnicityInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserReligionInputViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet var optionButtons: [UIButton]!
  @IBOutlet weak var noAnswerButton: UIButton!
  
  var allowsMultipleSelection: Bool = true
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserReligionInputViewController? {
    guard let ethnicityInputVC = R.storyboard.userReligionInputViewController
      .instantiateInitialViewController() else { return nil }
    return ethnicityInputVC
  }

  @IBAction func backButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.updateUser()
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func buttonOptionClicked(_ sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    sender.isSelected = !sender.isSelected
    if self.allowsMultipleSelection == false || sender == self.noAnswerButton {
      self.optionButtons.forEach({ $0.isSelected = false})
      sender.isSelected = true
    }
    
    if sender != self.noAnswerButton {
      self.noAnswerButton.isSelected = false
    }
    
    self.optionButtons.forEach({
      if $0.isSelected {
        $0.backgroundColor = R.color.primaryBrandColor()
      } else {
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
      }
    })
  }
  
  func updateUser() {
    var updatedReligion: [ReligionEnum] = []
    self.optionButtons.filter({ $0.isSelected}).forEach({
      switch $0.tag {
      case 0:
        updatedReligion.append(.buddhist)
      case 1:
        updatedReligion.append(.catholic)
      case 2:
        updatedReligion.append(.christian)
      case 3:
        updatedReligion.append(.hindu)
      case 4:
        updatedReligion.append(.jewish)
      case 5:
        updatedReligion.append(.muslim)
      case 6:
        updatedReligion.append(.spiritual)
      case 7:
        updatedReligion.append(.agnostic)
      case 8:
        updatedReligion.append(.atheist)
      case 9:
        updatedReligion.append(.other)
      case 10:
        updatedReligion = []
      default:
        break
      }
    })
    if self.optionButtons.filter({ $0.isSelected }).contains(self.noAnswerButton) {
      updatedReligion = []
    }
    DataStore.shared.currentPearUser?.matchingDemographics.religion.responses = updatedReligion
    if updatedReligion.count == 0 {
      DataStore.shared.currentPearUser?.matchingDemographics.religion.userHasResponded = false
    }
    PearUpdateUserAPI.shared.updateUserDemographicsItems(items: updatedReligion, keyName: "religion") { (result) in
      switch result {
      case .success(let successful):
        if successful {
          print("Successfully update user religion")
        } else {
          print("Failed to update user religion")
        }
      case .failure(let error):
        print("Failed to update user religion: \(error)")
      }

    }
  }
  
}

// MARK: - Life Cycle
extension UserReligionInputViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
//    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  func stylize() {
    self.optionButtons.forEach({
      $0.setTitleColor(R.color.primaryTextColor(), for: .normal)
      $0.setTitleColor(UIColor.white, for: .selected)
      $0.layer.cornerRadius = $0.frame.height / 2.0
      $0.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
      if let font = R.font.openSansBold(size: 14.0) {
        $0.titleLabel?.font = font
      }
    })

    self.titleLabel.stylizeOnboardingHeaderTitleLabel()
  }
  
  func setup() {
    guard let religion = DataStore.shared.currentPearUser?.matchingDemographics.religion.responses else {
      print("Current User not Found")
      return
    }
    if religion.count == 0 {
      self.buttonOptionClicked(self.noAnswerButton)
    } else {
      religion.forEach({
        var buttonTag = -1
        switch $0 {
        case .buddhist:
          buttonTag = 0
        case .catholic:
          buttonTag = 1
        case .christian:
          buttonTag = 2
        case .hindu:
          buttonTag = 3
        case .jewish:
          buttonTag = 4
        case .muslim:
          buttonTag = 5
        case .spiritual:
          buttonTag = 6
        case .agnostic:
          buttonTag = 7
        case .atheist:
          buttonTag = 8
        case .other:
          buttonTag = 9
        }
        if let button = self.optionButtons.filter({ $0.tag == buttonTag }).first {
          self.buttonOptionClicked(button)
        }
      })
    }
  }
  
}

// MARK: - UIGestureRecognizerDelegate
extension UserReligionInputViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
