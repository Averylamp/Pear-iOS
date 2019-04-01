//
//  GetStartedChooseGenderViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class GetStartedUserGenderViewController: UIViewController {
  
  @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
  let pageNumber: CGFloat = 1.0
  
  var gettingStartedData: UserCreationData!
  
  @IBOutlet weak var maleButton: UIButton!
  @IBOutlet weak var femaleButton: UIButton!
  @IBOutlet weak var nonbinaryButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedData: UserCreationData) -> GetStartedUserGenderViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedUserGenderViewController.self), bundle: nil)
    guard let chooseGenderVC = storyboard.instantiateInitialViewController() as? GetStartedUserGenderViewController else { return nil }
    chooseGenderVC.gettingStartedData = gettingStartedData
    return chooseGenderVC
  }
  
  @IBAction func chooseGenderButtonClicked(_ sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    
    switch sender.tag {
    case 0:
      self.gettingStartedData.gender = GenderEnum.male
      self.maleButton.stylizeDark()
      self.femaleButton.stylizeLight()
      self.nonbinaryButton.stylizeLight()
      
    case 1:
      self.gettingStartedData.gender = GenderEnum.female
      self.femaleButton.stylizeDark()
      self.maleButton.stylizeLight()
      self.nonbinaryButton.stylizeLight()
      
    case 2:
      self.gettingStartedData.gender = GenderEnum.nonbinary
      self.nonbinaryButton.stylizeDark()
      self.maleButton.stylizeLight()
      self.femaleButton.stylizeLight()
      
    default:
      break
    }
    guard let nextVC = self.gettingStartedData.getNextInputViewController() else {
      print("Failed to create next VC")
      return
    }
    self.navigationController?.pushViewController(nextVC, animated: true)
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
}

// MARK: - Life Cycle
extension GetStartedUserGenderViewController {
  
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
    
    if let previousGender = self.gettingStartedData.gender {
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
  }
  
}
