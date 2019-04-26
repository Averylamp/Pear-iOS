//
//  FinishSetupUserPreferencesViewController.swift
//  Pear
//
//  Created by Brian Gu on 4/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

class FinishSetupUserPreferencesViewController: UIViewController {
  
  private var initialGenderPreferences: [GenderEnum] = []
  var genderPreferences: [GenderEnum] = []
  var isSeeking: Bool = true
  
  @IBOutlet weak var maleGenderButton: UIButton!
  @IBOutlet weak var femaleGenderButton: UIButton!
  @IBOutlet weak var nonbinaryGenderButton: UIButton!
  @IBOutlet weak var relationshipButton: UIButton!
  @IBOutlet weak var maleSelectedIndicator: UIImageView!
  @IBOutlet weak var femaleSelectedIndicator: UIImageView!
  @IBOutlet weak var nonbinarySelectedIndicator: UIImageView!
  @IBOutlet weak var relationshipSelectedIndicator: UIImageView!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var nextButtonShadowView: UIView!
    
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> FinishSetupUserPreferencesViewController? {
    let storyboard = UIStoryboard(name: String(describing: FinishSetupUserPreferencesViewController.self), bundle: nil)
    guard let genderVC = storyboard.instantiateInitialViewController() as? FinishSetupUserPreferencesViewController else { return nil }
    return genderVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    var genderPrefs = self.genderPreferences.map({ $0.rawValue })
    
    self.view.endEditing(true)
    
    if !self.isSeeking {
      genderPrefs = [GenderEnum.male.rawValue, GenderEnum.female.rawValue, GenderEnum.nonbinary.rawValue]
    }
    
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("No user found")
      return
    }
    
    let buttons: [UIButton] = [self.maleGenderButton, self.femaleGenderButton, self.nonbinaryGenderButton, self.relationshipButton, self.nextButton]
    for idx in 0 ..< buttons.count {
      let button = buttons[idx]
      button.isEnabled = false
      button.alpha = 0.3
    }
    
    PearUserAPI.shared.updateUserPreferences(userID: userID,
                                             genderPrefs: genderPrefs,
                                             minAge: 18,
                                             maxAge: 30,
                                             locationName: nil,
                                             isSeeking: self.isSeeking) { (result) in
                                              switch result {
                                              case .success(let successful):
                                                if successful {
                                                  print("Update user was successful")
                                                } else {
                                                  print("Update user failed")
                                                }
                                                DispatchQueue.main.async {
                                                  guard let schoolVC = FinishSetupUserSchoolViewController.instantiate() else {
                                                    print("Failed to initialize school VC")
                                                    return
                                                  }
                                                  self.navigationController?.pushViewController(schoolVC, animated: true)
                                                }
                                              case .failure(let error):
                                                print("Update user failure: \(error)")
                                              }
                                              DispatchQueue.main.async {
                                                for idx in 0 ..< buttons.count {
                                                  let button = buttons[idx]
                                                  button.isEnabled = true
                                                  button.alpha = 1.0
                                                }
                                              }
    }
  }
  
  @IBAction func genderButtonToggled(_ sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    switch sender {
    case self.maleGenderButton:
      if isSeeking {
        if let index = genderPreferences.firstIndex(of: .male) {
          genderPreferences.remove(at: index)
        } else {
          genderPreferences.append(.male)
        }
      }
    case self.femaleGenderButton:
      if isSeeking {
        if let index = genderPreferences.firstIndex(of: .female) {
          genderPreferences.remove(at: index)
        } else {
          genderPreferences.append(.female)
        }
      }
    case self.nonbinaryGenderButton:
      if isSeeking {
        if let index = genderPreferences.firstIndex(of: .nonbinary) {
          genderPreferences.remove(at: index)
        } else {
          genderPreferences.append(.nonbinary)
        }
      }
    case self.relationshipButton:
      if isSeeking {
        isSeeking = false
        genderPreferences = []
      } else {
        isSeeking = true
      }
    default:
      break
    }
    
    self.stylizeButtons()
  }
  
}

// MARK: - Life Cycle
extension FinishSetupUserPreferencesViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.stylizeButtons()
  }
  
  func stylize() {
    self.nextButton.layer.cornerRadius = self.nextButton.frame.width / 2.0
    self.nextButtonShadowView.layer.cornerRadius = self.nextButton.frame.width / 2.0
    self.nextButtonShadowView.layer.shadowOpacity = 0.2
    self.nextButtonShadowView.layer.shadowColor = UIColor.black.cgColor
    self.nextButtonShadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
    self.nextButtonShadowView.layer.shadowRadius = 2
  }
  
  func stylizeButtons() {
    if self.genderPreferences.contains(.male) {
      self.maleGenderButton.stylizePreferencesOn()
      self.maleSelectedIndicator.isHidden = false
    } else {
      self.maleGenderButton.stylizePreferencesOff()
      self.maleSelectedIndicator.isHidden = true
    }
    
    if self.genderPreferences.contains(.female) {
      self.femaleGenderButton.stylizePreferencesOn()
      self.femaleSelectedIndicator.isHidden = false
    } else {
      self.femaleGenderButton.stylizePreferencesOff()
      self.femaleSelectedIndicator.isHidden = true
    }
    
    if self.genderPreferences.contains(.nonbinary) {
      self.nonbinaryGenderButton.stylizePreferencesOn()
      self.nonbinarySelectedIndicator.isHidden = false
    } else {
      self.nonbinaryGenderButton.stylizePreferencesOff()
      self.nonbinarySelectedIndicator.isHidden = true
    }
    
    if !self.isSeeking {
      self.relationshipButton.stylizePreferencesOn()
      self.relationshipSelectedIndicator.isHidden = false
    } else {
      self.relationshipButton.stylizePreferencesOff()
      self.relationshipSelectedIndicator.isHidden = true
    }
    
    if isSeeking && self.genderPreferences.count == 0 {
      self.nextButton.isHidden = true
      self.nextButtonShadowView.isHidden = true
    } else {
      self.nextButton.isHidden = false
      self.nextButtonShadowView.isHidden = true
    }
  }
  
}
