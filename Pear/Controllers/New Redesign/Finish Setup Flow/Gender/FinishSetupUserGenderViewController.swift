//
//  FinishSetupUserGenderViewController.swift
//  Pear
//
//  Created by Brian Gu on 4/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAnalytics

class FinishSetupUserGenderViewController: UIViewController {

  @IBOutlet weak var maleButton: UIButton!
  @IBOutlet weak var femaleButton: UIButton!
  @IBOutlet weak var nonbinaryButton: UIButton!
  
  var gender: GenderEnum?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> FinishSetupUserGenderViewController? {
    Analytics.logEvent(AnalyticsEventTutorialBegin, parameters: nil)
    let storyboard = UIStoryboard(name: String(describing: FinishSetupUserGenderViewController.self), bundle: nil)
    guard let genderVC = storyboard.instantiateInitialViewController() as? FinishSetupUserGenderViewController else { return nil }
    return genderVC
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    DispatchQueue.main.async {
      guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
        print("Failed to initialize Main VC")
        return
      }
      self.navigationController?.setViewControllers([mainVC], animated: true)
    }
  }
  
  @IBAction func chooseGenderButtonClicked(_ sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)

    switch sender.tag {
    case 0:
      self.gender = GenderEnum.male
      self.maleButton.stylizePreferencesOn()
      self.femaleButton.stylizePreferencesOff()
      self.nonbinaryButton.stylizePreferencesOff()
      
    case 1:
      self.gender = GenderEnum.female
      self.femaleButton.stylizePreferencesOn()
      self.maleButton.stylizePreferencesOff()
      self.nonbinaryButton.stylizePreferencesOff()
      
    case 2:
      self.gender = GenderEnum.nonbinary
      self.nonbinaryButton.stylizePreferencesOn()
      self.maleButton.stylizePreferencesOff()
      self.femaleButton.stylizePreferencesOff()
      
    default:
      break
    }
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Failed to get Current User")
      return
    }
    self.maleButton.isEnabled = false
    self.femaleButton.isEnabled = false
    self.nonbinaryButton.isEnabled = false
    self.maleButton.alpha = 0.3
    self.femaleButton.alpha = 0.3
    self.nonbinaryButton.alpha = 0.3
    if let gender = self.gender {
      Analytics.setUserProperty(gender.rawValue, forName: "gender")
      PearUserAPI.shared.updateUserGender(userID: userID, gender: gender) { (result) in
                                            switch result {
                                            case .success(let successful):
                                              if successful {
                                                print("Update user gender was successful")
                                              } else {
                                                print("Update user gender was unsuccessful")
                                              }
                                              DispatchQueue.main.async {
                                                guard let preferencesVC = FinishSetupUserPreferencesViewController.instantiate() else {
                                                  print("Failed to initialize Preferences VC")
                                                  return
                                                }
                                                Analytics.logEvent("FS_gender_DONE", parameters: nil)
                                                self.navigationController?.pushViewController(preferencesVC, animated: true)
                                              }
                                            case .failure(let error):
                                              print("Update user failure: \(error)")
                                            }
        DispatchQueue.main.async {
          self.maleButton.isEnabled = true
          self.femaleButton.isEnabled = true
          self.nonbinaryButton.isEnabled = true
          self.maleButton.alpha = 1.0
          self.femaleButton.alpha = 1.0
          self.nonbinaryButton.alpha = 1.0
        }
      }
    }
  }
  
}

// MARK: - Life Cycle
extension FinishSetupUserGenderViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    self.maleButton.stylizePreferencesOff()
    self.maleButton.tag = 0
    
    self.femaleButton.stylizePreferencesOff()
    self.femaleButton.tag = 1
    
    self.nonbinaryButton.stylizePreferencesOff()
    self.nonbinaryButton.tag = 2
    
    if let previousGender = self.gender {
      switch previousGender {
      case .male:
        self.maleButton.stylizePreferencesOn()
      case .female:
        self.femaleButton.stylizePreferencesOn()
      case .nonbinary:
        self.nonbinaryButton.stylizePreferencesOn()
      }
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.view.layoutIfNeeded()
  }
  
}
