//
//  OnboardingPreferencesViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class OnboardingPreferencesViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var relationshipButton: UIButton!
  
  @IBOutlet weak var relationshipButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingPreferencesViewController? {
    guard let onboardingFriendNameVC = R.storyboard.onboardingPreferencesViewController()
      .instantiateInitialViewController() as? OnboardingPreferencesViewController else { return nil }
    return onboardingFriendNameVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.continueToPicturesVC()
  }
  
  @IBAction func relationshipButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.continueToPicturesVC()
  }
  
  func continueToPicturesVC() {
    guard let picturesVC = OnboardingPicturesViewController.instantiate() else {
      print("Failed to instantiate pictures VC")
      return
    }
    self.navigationController?.pushViewController(picturesVC, animated: true)
  }
  
}

// MARK: - Life Cycle
extension OnboardingPreferencesViewController {
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
    self.relationshipButton.stylizeOnboardingContinueButton()
    self.relationshipButton.backgroundColor = UIColor(white: 0.87, alpha: 1.0)
    self.relationshipButton.setTitleColor(UIColor(white: 0.6, alpha: 1.0), for: .normal)
  }
  
  func setup() {
    
  }
  
}

// MARK: - Progress Bar Protocol
extension OnboardingPreferencesViewController: ProgressBarProtocol {
  var progressWidthConstraint: NSLayoutConstraint {
    return progressBarWidthConstraint
  }
  
  var progressBarCurrentPage: Int {
    return 3
  }
  
  var progressBarTotalPages: Int {
    return 4
  }
}

// MARK: - KeyboardEventsBottomProtocol
extension OnboardingPreferencesViewController: KeyboardEventsBottomProtocol {
  var bottomKeyboardConstraint: NSLayoutConstraint? {
    return self.relationshipButtonBottomConstraint
  }
  
  var bottomKeyboardPadding: CGFloat {
    return 20.0
  }
}
