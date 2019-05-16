//
//  OnboardingMoreDetailsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class OnboardingMoreDetailsViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var stackView: UIStackView!t
  @IBOutlet weak var continueButton: UIButton!
  
  @IBOutlet weak var continueButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingMoreDetailsViewController? {
    guard let onboardingMoreDetailsVC = R.storyboard.onboardingMoreDetailsViewController()
      .instantiateInitialViewController() as? OnboardingMoreDetailsViewController else { return nil }
    return onboardingMoreDetailsVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let preferencesVC = OnboardingPreferencesViewController.instantiate() else {
      print("Failed to instantiate preferences VC")
      return
    }
    self.navigationController?.pushViewController(preferencesVC, animated: true)
  }
  
}

// MARK: - Life Cycle
extension OnboardingMoreDetailsViewController {
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
extension OnboardingMoreDetailsViewController: ProgressBarProtocol {
  var progressWidthConstraint: NSLayoutConstraint {
    return progressBarWidthConstraint
  }
  
  var progressBarCurrentPage: Int {
    return 2
  }
  
  var progressBarTotalPages: Int {
    return 4
  }
}

// MARK: - KeyboardEventsBottomProtocol
extension OnboardingMoreDetailsViewController: KeyboardEventsBottomProtocol {
  var bottomKeyboardConstraint: NSLayoutConstraint? {
    return self.continueButtonBottomConstraint
  }
  
  var bottomKeyboardPadding: CGFloat {
    return 20.0
  }
}
