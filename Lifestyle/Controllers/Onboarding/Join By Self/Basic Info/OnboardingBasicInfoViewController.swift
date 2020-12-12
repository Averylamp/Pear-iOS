//
//  OnboardingBasicInfoViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class OnboardingBasicInfoViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var headerView: UIView!

  @IBOutlet weak var continueButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
  
  var basicInfoVC: UserBasicInfoTableViewController?
  
  let initializationTime: Double = CACurrentMediaTime()
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingBasicInfoViewController? {
    Analytics.logEvent("setup_profile_begin", parameters: nil)
    guard let onboardingFriendNameVC = R.storyboard.onboardingBasicInfoViewController
      .instantiateInitialViewController()  else { return nil }
    return onboardingFriendNameVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    SlackHelper.shared.addEvent(text: "User went back from Join Alone flow in \(round((CACurrentMediaTime() - self.initializationTime) * 100) / 100)s", color: UIColor.red)
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    if let basicInfoVC = self.basicInfoVC {
      let requiredUnfilledItems = basicInfoVC.infoItems.filter({ $0.requiredFilledOut == true && $0.filledOut == false })
      if requiredUnfilledItems.count > 0 {
        let alertController = UIAlertController(title: "You have missing required information",
                                                message: "Please fill out \(requiredUnfilledItems.map({ $0.type.toTitleString()}).joined(separator: ", "))",
          preferredStyle: .alert)
        SlackHelper.shared.addEvent(text: "User tried to continue without filling out \(requiredUnfilledItems.map({ $0.type.toTitleString()}).joined(separator: ", ")) in \(round((CACurrentMediaTime() - self.initializationTime) * 100) / 100)s.", color: UIColor.red)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(okayAction)
        self.present(alertController, animated: true, completion: nil)
      } else {
        SlackHelper.shared.addEvent(text: "Continuing to More User Details in \(round((CACurrentMediaTime() - self.initializationTime) * 100) / 100)s.)", color: UIColor.green)
        self.continueToMoreDetailsVC()
      }
    } else {
      self.continueToMoreDetailsVC()
      SlackHelper.shared.addEvent(text: "Continuing to More User Details in \(round((CACurrentMediaTime() - self.initializationTime) * 100) / 100)s.)", color: UIColor.green)
    }
  }
  
  func continueToMoreDetailsVC() {
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
    self.basicInfoVC = basicInfoInputVC
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
