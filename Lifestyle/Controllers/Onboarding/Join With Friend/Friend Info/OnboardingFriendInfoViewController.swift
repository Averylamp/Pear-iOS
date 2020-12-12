//
//  OnboardingFriendInfoViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import MessageUI
import FirebaseAnalytics
import ContactsUI

class OnboardingFriendInfoViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet var labelGroup: [UILabel]!
  @IBOutlet var headerLabelGroup: [UILabel]!
  
  @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
  
  var responseInputVC: SimpleFieldInputViewController?
  
  var profileData: ProfileCreationData!
  var activityIndicator = NVActivityIndicatorView(frame: CGRect.zero)
  var titleLabelText: String?

  let initializationTime: Double = CACurrentMediaTime()
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(profileData: ProfileCreationData, titleLabelText: String? = nil) -> OnboardingFriendInfoViewController? {
    Analytics.logEvent("invite_friend_begin", parameters: nil)
    guard let onboardingFriendInfoVC = R.storyboard.onboardingFriendInfoViewController
      .instantiateInitialViewController()  else { return nil }
    onboardingFriendInfoVC.titleLabelText = titleLabelText
    onboardingFriendInfoVC.profileData = profileData
    return onboardingFriendInfoVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    SlackHelper.shared.addEvent(text: "User went back from Friend Info VC", color: UIColor.red)
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let friendNameInputVC = OnboardingFriendNameViewController.instantiate(profileData: self.profileData,
                                                                                 titleLabelText: self.titleLabelText) else {
      print("Unable to create friend name input VC")
      return
    }
    SlackHelper.shared.addEvent(text: "User Continued past Friend Info in \(round((CACurrentMediaTime() - self.initializationTime) * 100) / 100)s.  Continuing to Friend Name VC", color: UIColor.green)
    self.navigationController?.pushViewController(friendNameInputVC, animated: true)
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
    if let titleLabelText = self.titleLabelText {
      self.titleLabel.text = titleLabelText
    }
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
    return 1
  }
  
  var progressBarTotalPages: Int {
    return 3
  }
}
