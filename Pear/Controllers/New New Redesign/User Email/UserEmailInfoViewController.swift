//
//  UserEmailInfoViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/15/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserEmailInfoViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var phoneNumberContainerView: UIView!
  @IBOutlet weak var phoneNumberInputTextField: UITextField!
  @IBOutlet weak var emailContainerView: UIView!
  @IBOutlet weak var emailInputTextField: UITextField!
  @IBOutlet weak var continueButtonBottomConstraint: NSLayoutConstraint!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserEmailInfoViewController? {
    guard let emailInfoVC = R.storyboard.userEmailInfoViewController().instantiateInitialViewController() as? UserEmailInfoViewController else { return nil }
    
    return emailInfoVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    
  }
  
}

// MARK: - Life Cycle
extension UserEmailInfoViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
    self.addKeyboardNotifications(animated: true)
    self.addKeyboardDismissOnTap()
  }
  
  func stylize() {
    self.titleLabel.stylizeOnboardingTitleLabel()
    self.phoneNumberContainerView.layer.cornerRadius = 12
    self.emailContainerView.layer.cornerRadius = 12
    self.emailContainerView.layer.borderWidth = 1
    self.emailContainerView.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    self.continueButton.layer.cornerRadius = self.continueButton.frame.height / 2.0
  }
  
  func setup() {
    guard let phoneNumber = DataStore.shared.currentPearUser?.phoneNumber else {
      print("Failed to get phone number")
      return
    }
    self.phoneNumberInputTextField.text = String.formatPhoneNumber(phoneNumber: phoneNumber)
    
  }
  
}

// MARK: - KeyboardEventsBottomProtocol
extension UserEmailInfoViewController: KeyboardEventsBottomProtocol {
  
  var bottomKeyboardConstraint: NSLayoutConstraint? {
    return continueButtonBottomConstraint
  }
  
  var bottomKeyboardPadding: CGFloat {
    return 20.0
  }
  
}

// MARK: - KeyboardEventsDismissTapProtocol
extension UserEmailInfoViewController: KeyboardEventsDismissTapProtocol {
  func addKeyboardDismissOnTap() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserEmailInfoViewController.backgroundViewTapped)))
  }
  
  @objc func backgroundViewTapped() {
    self.dismissKeyboard()
  }
}
