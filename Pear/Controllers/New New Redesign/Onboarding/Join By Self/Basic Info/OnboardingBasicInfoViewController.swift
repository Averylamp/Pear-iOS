//
//  OnboardingBasicInfoViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class OnboardingBasicInfoViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var headerView: UIView!

  @IBOutlet weak var continueButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingBasicInfoViewController? {
    guard let onboardingFriendNameVC = R.storyboard.onboardingBasicInfoViewController()
      .instantiateInitialViewController() as? OnboardingBasicInfoViewController else { return nil }
    return onboardingFriendNameVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let moreDetailsVC = OnboardingMoreDetailsViewController.instantiate() else {
      print("Failed to instantiate more details VC")
      return
    }
    self.navigationController?.pushViewController(moreDetailsVC, animated: true)
  }
  
}

// MARK: - Life Cycle
extension OnboardingBasicInfoViewController {
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
    guard let basicInfoInputVC = UserBasicInfoTableViewController.instantiate() else {
      print("Unable to instantiate basic info VC")
      return
    }
    self.addChild(basicInfoInputVC)
    self.view.addSubview(basicInfoInputVC.view)
    self.view.addConstraints([
      NSLayoutConstraint(item: basicInfoInputVC.view as Any, attribute: .top, relatedBy: .equal,
                         toItem: self.headerView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: basicInfoInputVC.view as Any, attribute: .bottom, relatedBy: .equal,
                         toItem: self.continueButton, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: basicInfoInputVC.view as Any, attribute: .left, relatedBy: .equal,
                         toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: basicInfoInputVC.view as Any, attribute: .right, relatedBy: .equal,
                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
      ])
    basicInfoInputVC.view.translatesAutoresizingMaskIntoConstraints = false
    basicInfoInputVC.didMove(toParent: self)
  }
  
}

// MARK: - Progress Bar Protocol
extension OnboardingBasicInfoViewController: ProgressBarProtocol {
  var progressWidthConstraint: NSLayoutConstraint {
    return progressBarWidthConstraint
  }
  
  var progressBarCurrentPage: Int {
    return 1
  }
  
  var progressBarTotalPages: Int {
    return 4
  }
}

// MARK: - KeyboardEventsBottomProtocol
extension OnboardingBasicInfoViewController: KeyboardEventsBottomProtocol {
  var bottomKeyboardConstraint: NSLayoutConstraint? {
    return self.continueButtonBottomConstraint
  }
  
  var bottomKeyboardPadding: CGFloat {
    return 20.0
  }
}
