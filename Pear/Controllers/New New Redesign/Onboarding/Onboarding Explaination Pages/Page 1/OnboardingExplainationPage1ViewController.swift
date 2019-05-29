//
//  OnboardingExplainationPage1ViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class OnboardingExplainationPage1ViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var memeImageView: UIImageView!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingExplainationPage1ViewController? {
    guard let onboardingPage1VC = R.storyboard.onboardingExplainationPage1ViewController
      .instantiateInitialViewController()  else { return nil }
    
    return onboardingPage1VC
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let nextOnboardingInfoPage = OnboardingExplainationPage2ViewController.instantiate() else {
      print("Failed to create next Onboarding Info Page")
      return
    }
    self.navigationController?.pushViewController(nextOnboardingInfoPage, animated: true)
  }
  
}

// MARK: - Life Cycle
extension OnboardingExplainationPage1ViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.stylize()
  }

  func stylize() {
    self.titleLabel.stylizeOnboardingMemeTitleLabel()
    self.continueButton.stylizeOnboardingContinueButton()
    self.memeImageView.stylizeOnboardingMemeImage()
  }
  
}
