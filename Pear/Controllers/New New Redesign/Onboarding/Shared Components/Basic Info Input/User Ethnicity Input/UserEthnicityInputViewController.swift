//
//  UserEthnicityInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserEthnicityInputViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet var optionButtons: [UIButton]!
  @IBOutlet weak var noAnswerButton: UIButton!
  
  var allowsMultipleSelection: Bool = true
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserEthnicityInputViewController? {
    guard let ethnicityInputVC = R.storyboard.userEthnicityInputViewController()
      .instantiateInitialViewController() as? UserEthnicityInputViewController else { return nil }
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
    var updatedEthnicities: [EthnicityEnum] = []
    self.optionButtons.filter({ $0.isSelected}).forEach({
      switch $0.tag {
      case 0:
        updatedEthnicities.append(.americanIndian)
      case 1:
        updatedEthnicities.append(.blackAfrican)
      case 2:
        updatedEthnicities.append(.eastAsian)
      case 3:
        updatedEthnicities.append(.hispanicLatino)
      case 4:
        updatedEthnicities.append(.middleEastern)
      case 5:
        updatedEthnicities.append(.pacificIslander)
      case 6:
        updatedEthnicities.append(.southAsian)
      case 7:
        updatedEthnicities.append(.whiteCaucasian)
      case 8:
        updatedEthnicities.append(.other)
      case 9:
        updatedEthnicities = []
      default:
        break
      }
    })
    if self.optionButtons.filter({ $0.isSelected }).contains(self.noAnswerButton) {
      updatedEthnicities = []
    }
    DataStore.shared.currentPearUser?.matchingDemographics.ethnicity.responses = updatedEthnicities
    if updatedEthnicities.count == 0 {
      DataStore.shared.currentPearUser?.matchingDemographics.ethnicity.userHasResponded = false
    }
    PearUpdateUserAPI.shared.updateUserDemographicsItems(items: updatedEthnicities, keyName: "ethnicity") { (result) in
      switch result {
      case .success(let successful):
        if successful {
          print("Successfully update user ethnicity")
        } else {
          print("Failed to update user ethnicity")
        }
      case .failure(let error):
        print("Failed to update user ethnicity: \(error)")
      }

    }
  }
  
}

// MARK: - Life Cycle
extension UserEthnicityInputViewController {
  
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
    guard let ethnicities = DataStore.shared.currentPearUser?.matchingDemographics.ethnicity.responses else {
      print("Current User not Found")
      return
    }
    if ethnicities.count == 0 {
      self.buttonOptionClicked(self.noAnswerButton)
    } else {
      ethnicities.forEach({
        var buttonTag = -1
        switch $0 {
        case .americanIndian:
          buttonTag = 0
        case .blackAfrican:
          buttonTag = 1
        case .eastAsian:
          buttonTag = 2
        case .hispanicLatino:
          buttonTag = 3
        case .middleEastern:
          buttonTag = 4
        case .pacificIslander:
          buttonTag = 5
        case .southAsian:
          buttonTag = 6
        case .whiteCaucasian:
          buttonTag = 7
        case .other:
          buttonTag = 8
        }
        if let button = self.optionButtons.filter({ $0.tag == buttonTag }).first {
          self.buttonOptionClicked(button)
        }
      })
    }
  }
  
}

// MARK: - UIGestureRecognizerDelegate
extension UserEthnicityInputViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
