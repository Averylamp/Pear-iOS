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
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var continueButton: UIButton!
  
  @IBOutlet weak var continueButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingMoreDetailsViewController? {
    guard let onboardingMoreDetailsVC = R.storyboard.onboardingMoreDetailsViewController
      .instantiateInitialViewController()  else { return nil }
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
    guard let moreDetailsVC = UserMoreDetailsTableViewController.instantiate() else {
      print("Unable to instantiate basic info VC")
      return
    }
    self.addChild(moreDetailsVC)
    self.view.addSubview(moreDetailsVC.view)
    self.view.addConstraints([
      NSLayoutConstraint(item: moreDetailsVC.view as Any, attribute: .top, relatedBy: .equal,
                         toItem: self.headerView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: moreDetailsVC.view as Any, attribute: .bottom, relatedBy: .equal,
                         toItem: self.continueButton, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: moreDetailsVC.view as Any, attribute: .left, relatedBy: .equal,
                         toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: moreDetailsVC.view as Any, attribute: .right, relatedBy: .equal,
                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
      ])
    moreDetailsVC.view.translatesAutoresizingMaskIntoConstraints = false
    moreDetailsVC.didMove(toParent: self)
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
