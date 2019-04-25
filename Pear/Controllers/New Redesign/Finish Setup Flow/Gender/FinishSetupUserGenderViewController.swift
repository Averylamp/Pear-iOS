//
//  FinishSetupUserGenderViewController.swift
//  Pear
//
//  Created by Brian Gu on 4/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

class FinishSetupUserGenderViewController: UIViewController {

  @IBOutlet weak var maleButton: UIButton!
  @IBOutlet weak var femaleButton: UIButton!
  @IBOutlet weak var nonbinaryButton: UIButton!
  
  var gender: GenderEnum?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> FinishSetupUserGenderViewController? {
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
      self.maleButton.stylizeDark()
      self.femaleButton.stylizeLight()
      self.nonbinaryButton.stylizeLight()
      
    case 1:
      self.gender = GenderEnum.female
      self.femaleButton.stylizeDark()
      self.maleButton.stylizeLight()
      self.nonbinaryButton.stylizeLight()
      
    case 2:
      self.gender = GenderEnum.nonbinary
      self.nonbinaryButton.stylizeDark()
      self.maleButton.stylizeLight()
      self.femaleButton.stylizeLight()
      
    default:
      break
    }
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Failed to get Current User")
      return
    }
    if let gender = self.gender {
      PearUserAPI.shared.updateUserGender(userID: userID, gender: gender) { (result) in
                                            switch result {
                                            case .success(let successful):
                                              if successful {
                                                print("Update user gender was successful")
                                              } else {
                                                print("Update user gender was unsuccessful")
                                              }
                                              DispatchQueue.main.async {
                                                guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
                                                  print("Failed to initialize Main VC")
                                                  return
                                                }
                                                self.navigationController?.setViewControllers([mainVC], animated: true)
                                              }
                                              /*
                                              DispatchQueue.main.async {
                                                guard let nextVC = FinishSetupPreferencesViewController.instantiate() else {
                                                  print("Failed to create next VC")
                                                  return
                                                }
                                                self.navigationController?.pushViewController(nextVC, animated: true)
                                              }
                                              */
                                            case .failure(let error):
                                              print("Update user failure: \(error)")
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
    self.maleButton.stylizeLight()
    self.maleButton.tag = 0
    
    self.femaleButton.stylizeLight()
    self.femaleButton.tag = 1
    
    self.nonbinaryButton.stylizeLight()
    self.nonbinaryButton.tag = 2
    
    if let previousGender = self.gender {
      switch previousGender {
      case .male:
        self.maleButton.stylizeDark()
      case .female:
        self.femaleButton.stylizeDark()
      case .nonbinary:
        self.nonbinaryButton.stylizeDark()
      }
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.view.layoutIfNeeded()
  }
  
}
