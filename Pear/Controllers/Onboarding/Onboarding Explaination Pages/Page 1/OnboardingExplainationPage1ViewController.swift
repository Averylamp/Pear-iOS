//
//  OnboardingExplainationPage1ViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class OnboardingExplainationPage1ViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var memeImageView: UIImageView!
  
  let initializationTime: Double = CACurrentMediaTime()
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingExplainationPage1ViewController? {
    Analytics.logEvent("how_it_works_begin", parameters: nil)
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
    SlackHelper.shared.addEvent(text: "User Continued to 2nd Onboarding page in \(round((CACurrentMediaTime() - initializationTime) * 100) / 100)s", color: UIColor.yellow)
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
