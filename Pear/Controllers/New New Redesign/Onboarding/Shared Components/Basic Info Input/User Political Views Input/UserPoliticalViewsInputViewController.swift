//
//  UserEthnicityInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserPoliticalViewsInputViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet var optionButtons: [UIButton]!
  @IBOutlet weak var noAnswerButton: UIButton!
  
  var allowsMultipleSelection: Bool = false
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserPoliticalViewsInputViewController? {
    guard let ethnicityInputVC = R.storyboard.userPoliticalViewsInputViewController
      .instantiateInitialViewController()  else { return nil }
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
    var updatedPoliticalView: PoliticsEnum = .preferNotToSay
    self.optionButtons.filter({ $0.isSelected}).forEach({
      switch $0.tag {
      case 0:
        updatedPoliticalView = .liberal
      case 1:
        updatedPoliticalView = .moderate
      case 2:
        updatedPoliticalView = .conservative
      case 3:
        updatedPoliticalView = .other
      case 4:
        updatedPoliticalView = .preferNotToSay
      default:
        updatedPoliticalView = .preferNotToSay
      }
    })
    if self.optionButtons.filter({ $0.isSelected }).contains(self.noAnswerButton) {
      updatedPoliticalView = .preferNotToSay
    }
    DataStore.shared.currentPearUser?.matchingDemographics.politicalView.responses = [updatedPoliticalView]
    if updatedPoliticalView == .preferNotToSay {
      DataStore.shared.currentPearUser?.matchingDemographics.politicalView.userHasResponded = false
    }
    PearUpdateUserAPI.shared.updateUserDemographicsItem(item: updatedPoliticalView, keyName: "politicalView") { (result) in
      switch result {
      case .success(let successful):
        if successful {
          print("Successfully update user PoliticalView")
        } else {
          print("Failed to update user PoliticalView")
        }
      case .failure(let error):
        print("Failed to update user PoliticalView: \(error)")
      }
    }
  }
  
}

// MARK: - Life Cycle
extension UserPoliticalViewsInputViewController {
  
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
    guard let ethnicities = DataStore.shared.currentPearUser?.matchingDemographics.politicalView.responses else {
      print("Current User not Found")
      return
    }
    if ethnicities.count == 0 {
      self.buttonOptionClicked(self.noAnswerButton)
    } else {
      ethnicities.forEach({
        var buttonTag = -1
        switch $0 {
        case .liberal:
          buttonTag = 0
        case .moderate:
          buttonTag = 1
        case .conservative:
          buttonTag = 2
        case .other:
          buttonTag = 3
        case .preferNotToSay:
          buttonTag = 4
        }
        if let button = self.optionButtons.filter({ $0.tag == buttonTag }).first {
          self.buttonOptionClicked(button)
        }
      })
    }
  }
  
}

// MARK: - UIGestureRecognizerDelegate
extension UserPoliticalViewsInputViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
