//
//  OnboardingExplainationPage1ViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class OnboardingExplainationPage4ViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var memeImageView: UIImageView!
  
  @IBOutlet weak var joinWithFriendButton: UIButton!
  @IBOutlet weak var joinBySelfButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingExplainationPage4ViewController? {
    guard let onboardingPage4VC = R.storyboard.onboardingExplainationPage4ViewController
      .instantiateInitialViewController()  else { return nil }
    
    return onboardingPage4VC
  }
  
  @IBAction func joinWithFriendClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    Analytics.logEvent("how_it_works_complete", parameters: nil)
    guard let joinFriendInfoVC = OnboardingFriendInfoViewController.instantiate() else {
      print("Failed to create next Onboarding Info Page")
      return
    }
    self.navigationController?.pushViewController(joinFriendInfoVC, animated: true)
  }
  
  @IBAction func joinBySelfClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    Analytics.logEvent("how_it_works_complete", parameters: nil)
    guard let basicInfoVC = OnboardingBasicInfoViewController.instantiate() else {
      print("Failed to create next Onboarding Info Page")
      return
    }
    self.navigationController?.pushViewController(basicInfoVC, animated: true)
  }
}

// MARK: - Life Cycle
extension OnboardingExplainationPage4ViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }

  func stylize() {
    self.titleLabel.stylizeOnboardingMemeTitleLabel()
    self.memeImageView.stylizeOnboardingMemeImage()
    self.joinWithFriendButton.stylizeOnboardingContinueButton()
    self.joinBySelfButton.stylizeOnboardingContinueButton()
    self.joinBySelfButton.backgroundColor = UIColor(white: 0.87, alpha: 1.0)
    self.joinBySelfButton.setTitleColor(UIColor(white: 0.6, alpha: 1.0), for: .normal)
  }
  
}
