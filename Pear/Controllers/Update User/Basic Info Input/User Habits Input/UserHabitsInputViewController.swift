//
//  UserEthnicityInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

enum HabitInputType: String {
  case drinking
  case smoking
  case cannabis
  case drugs
}

class UserHabitsInputViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet var optionButtons: [UIButton]!
  @IBOutlet weak var noAnswerButton: UIButton!
  
  var allowsMultipleSelection: Bool = false
  var habitType: HabitInputType!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(habitType: HabitInputType) -> UserHabitsInputViewController? {
    guard let habitInputVC = R.storyboard.userHabitsInputViewController
      .instantiateInitialViewController() else { return nil }
    habitInputVC.habitType = habitType
    return habitInputVC
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
    var updatedHabit: HabitsEnum = .preferNotToSay
    self.optionButtons.filter({ $0.isSelected}).forEach({
      switch $0.tag {
      case 0:
        updatedHabit = .yes
      case 1:
        updatedHabit = .sometimes
      case 2:
        updatedHabit = .no
      case 3:
        updatedHabit = .preferNotToSay
      default:
        updatedHabit = .preferNotToSay
      }
    })
    if self.optionButtons.filter({ $0.isSelected }).contains(self.noAnswerButton) {
      updatedHabit = .preferNotToSay
    }
    switch self.habitType! {
    case .drinking:
      DataStore.shared.currentPearUser?.matchingDemographics.drinking.responses = [updatedHabit]
    case .smoking:
      DataStore.shared.currentPearUser?.matchingDemographics.smoking.responses = [updatedHabit]
    case .cannabis:
      DataStore.shared.currentPearUser?.matchingDemographics.cannabis.responses = [updatedHabit]
    case .drugs:
      DataStore.shared.currentPearUser?.matchingDemographics.drugs.responses = [updatedHabit]
    }
    PearUpdateUserAPI.shared.updateUserDemographicsItem(item: updatedHabit, keyName: self.habitType!.rawValue) { (result) in
      switch result {
      case .success(let successful):
        if successful {
          print("Successfully update user \(self.habitType.rawValue)")
        } else {
          print("Failed to update user \(self.habitType.rawValue)")
        }
      case .failure(let error):
        print("Failed to update user \(self.habitType.rawValue): \(error)")
      }

    }
  }
  
}

// MARK: - Life Cycle
extension UserHabitsInputViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
//    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  func stylize() {
    self.titleLabel.text = self.habitType.rawValue.firstCapitalized
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
    var habits: [HabitsEnum] = []
    switch self.habitType! {
    case .drinking:
      if let foundHabits = DataStore.shared.currentPearUser?.matchingDemographics.drinking.responses {
        habits = foundHabits
      }
    case .smoking:
      if let foundHabits = DataStore.shared.currentPearUser?.matchingDemographics.smoking.responses {
        habits = foundHabits
      }
    case .cannabis:
      if let foundHabits = DataStore.shared.currentPearUser?.matchingDemographics.cannabis.responses {
        habits = foundHabits
      }
    case .drugs:
      if let foundHabits = DataStore.shared.currentPearUser?.matchingDemographics.drugs.responses {
        habits = foundHabits
      }
    }
    
    if habits.count == 0 {
      self.buttonOptionClicked(self.noAnswerButton)
    } else {
      habits.forEach({
        var buttonTag = -1
        switch $0 {
        case .yes:
          buttonTag = 0
        case .sometimes:
          buttonTag = 1
        case .no:
          buttonTag = 2
        case .preferNotToSay:
          buttonTag = 3
        }
        if let button = self.optionButtons.filter({ $0.tag == buttonTag }).first {
          self.buttonOptionClicked(button)
        }
      })
    }
  }
  
}

// MARK: - UIGestureRecognizerDelegate
extension UserHabitsInputViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
