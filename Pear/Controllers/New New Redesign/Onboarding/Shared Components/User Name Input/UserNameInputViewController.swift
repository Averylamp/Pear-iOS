//
//  UserNameInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserNameInputViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  
  @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserNameInputViewController? {
    guard let userNameVC = R.storyboard.userNameInputViewController()
      .instantiateInitialViewController() as? UserNameInputViewController else { return nil }
    return userNameVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.navigationController?.popViewController(animated: true)
  }
  
}

// MARK: - Life Cycle
extension UserNameInputViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
    self.addKeyboardNotifications(animated: true)
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  func stylize() {
    self.titleLabel.stylizeOnboardingHeaderTitleLabel()
  }
  
  func setup() {
    
  }
  
}

// MARK: - KeyboardEventsBottomProtocol
extension UserNameInputViewController: KeyboardEventsBottomProtocol {
  var bottomKeyboardConstraint: NSLayoutConstraint? {
    return self.scrollViewBottomConstraint
  }
  
  var bottomKeyboardPadding: CGFloat {
    return 0.0
  }
}

// MARK: - UIGestureRecognizerDelegate
extension UserNameInputViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
