//
//  OnboardingFriendInfoViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class OnboardingFriendInfoViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet var labelGroup: [UILabel]!
  @IBOutlet var headerLabelGroup: [UILabel]!
  
  @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingFriendInfoViewController? {
    guard let onboardingFriendInfoVC = R.storyboard.onboardingFriendInfoViewController()
      .instantiateInitialViewController() as? OnboardingFriendInfoViewController else { return nil }
    return onboardingFriendInfoVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
  }
  
}

// MARK: - Life Cycle
extension OnboardingFriendInfoViewController {
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
    if UIScreen.main.bounds.width <= 320 {
      labelGroup.forEach {
        if let font = R.font.openSansSemiBold(size: 13) {
          $0.font = font
        }
      }
      headerLabelGroup.forEach {
        if let font = R.font.openSansBold(size: 16) {
          $0.font = font
        }
      }
    }
  }
  
  func setup() {
    
  }
  
}

// MARK: - Progress Bar Protocol
extension OnboardingFriendInfoViewController: ProgressBarProtocol {
  var progressWidthConstraint: NSLayoutConstraint {
    return progressBarWidthConstraint
  }
  
  var progressBarCurrentPage: Int {
    return 2
  }
  
  var progressBarTotalPages: Int {
    return 2
  }
}
