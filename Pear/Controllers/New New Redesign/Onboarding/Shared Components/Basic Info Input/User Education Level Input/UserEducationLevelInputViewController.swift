//
//  UserEthnicityInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserEducationLevelInputViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet var optionButtons: [UIButton]!
  @IBOutlet weak var noAnswerButton: UIButton!
  
  var allowsMultipleSelection: Bool = false
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserEducationLevelInputViewController? {
    guard let ethnicityInputVC = R.storyboard.userEducationLevelInputViewController()
      .instantiateInitialViewController() as? UserEducationLevelInputViewController else { return nil }
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
    var educationLevel: EducationLevelEnum = .highSchool
    self.optionButtons.filter({ $0.isSelected}).forEach({
      switch $0.tag {
      case 0:
        educationLevel = .highSchool
      case 1:
        educationLevel = .underGrad
      case 2:
        educationLevel = .postGrad
      case 3:
        educationLevel = .highSchool
      default:
        break
      }
    })
    if self.optionButtons.filter({ $0.isSelected }).contains(self.noAnswerButton) {
      educationLevel = .highSchool
    }
    
    DataStore.shared.currentPearUser?.matchingDemographics.educationLevel.responses = [educationLevel]
    PearUpdateUserAPI.shared.updateUserDemographicsItem(item: educationLevel, keyName: "educationLevel") { (result) in
      switch result {
      case .success(let successful):
        if successful {
          print("Successfully update user educationLevel")
        } else {
          print("Failed to update user educationLevel")
        }
      case .failure(let error):
        print("Failed to update user educationLevel: \(error)")
      }

    }
  }
  
}

// MARK: - Life Cycle
extension UserEducationLevelInputViewController {
  
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
    guard let educationLevels = DataStore.shared.currentPearUser?.matchingDemographics.educationLevel.responses else {
      print("Current User not Found")
      return
    }
    if educationLevels.count == 0 {
      self.buttonOptionClicked(self.noAnswerButton)
    } else {
      educationLevels.forEach({
        var buttonTag = -1
        switch $0 {
        case .highSchool:
          buttonTag = 0
        case .underGrad:
          buttonTag = 1
        case .postGrad:
          buttonTag = 2
        }
        if let button = self.optionButtons.filter({ $0.tag == buttonTag }).first {
          self.buttonOptionClicked(button)
        }
      })
    }
  }
  
}

// MARK: - UIGestureRecognizerDelegate
extension UserEducationLevelInputViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
