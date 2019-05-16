//
//  OnboardingPicturesViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class OnboardingPicturesViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  
  @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingPicturesViewController? {
    guard let onboardingPicturesVC = R.storyboard.onboardingPicturesViewController()
      .instantiateInitialViewController() as? OnboardingPicturesViewController else { return nil }
    return onboardingPicturesVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let preferencesVC = OnboardingBasicInfoViewController.instantiate() else {
      print("Failed to instantiate preferences VC")
      return
    }
    self.navigationController?.pushViewController(preferencesVC, animated: true)
  }
  
}

// MARK: - Life Cycle
extension OnboardingPicturesViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
    self.setPreviousPageProgress()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.setCurrentPageProgress(animated: animated)
  }
  
  func stylize() {
    self.titleLabel.stylizeOnboardingHeaderTitleLabel()
    self.continueButton.stylizeOnboardingContinueButton()
  }
  
  func setup() {
    
  }
  
}

// MARK: - Progress Bar Protocol
extension OnboardingPicturesViewController: ProgressBarProtocol {
  var progressWidthConstraint: NSLayoutConstraint {
    return progressBarWidthConstraint
  }
  
  var progressBarCurrentPage: Int {
    return 4
  }
  
  var progressBarTotalPages: Int {
    return 4
  }
}
