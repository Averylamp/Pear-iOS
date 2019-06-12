//
//  OnboardingExplainationPage1ViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class OnboardingExplainationPage2ViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var memeImageView: UIImageView!
  
  let initializationTime: Double = CACurrentMediaTime()
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingExplainationPage2ViewController? {
    guard let onboardingPage2VC = R.storyboard.onboardingExplainationPage2ViewController
      .instantiateInitialViewController()  else { return nil }
    return onboardingPage2VC
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let nextOnboardingInfoPage = OnboardingExplainationPage3ViewController.instantiate() else {
      print("Failed to create next Onboarding Info Page")
      return
    }
    SlackHelper.shared.addEvent(text: "User Continued to 3rd Onboarding page in \(round((CACurrentMediaTime() - initializationTime) * 100) / 100)s", color: UIColor.yellow)
    self.navigationController?.pushViewController(nextOnboardingInfoPage, animated: true)
  }
  
}

// MARK: - Life Cycle
extension OnboardingExplainationPage2ViewController {
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
