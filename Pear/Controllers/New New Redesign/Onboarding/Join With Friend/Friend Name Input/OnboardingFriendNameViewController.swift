//
//  OnboardingFriendNameViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class OnboardingFriendNameViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var continueButton: UIButton!
  
  @IBOutlet weak var continueButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
  
  var firstNameVC: SimpleFieldInputViewController?
  var genderButtons: [UIButton] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingFriendNameViewController? {
    guard let onboardingFriendNameVC = R.storyboard.onboardingFriendNameViewController()
      .instantiateInitialViewController() as? OnboardingFriendNameViewController else { return nil }
    return onboardingFriendNameVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    
    guard let friendFirstName = self.firstNameVC?.getNewFieldValue() else {
      self.alert(title: "Missing Info", message: "You must fill out your friend's first name")
      return
    }
    var friendsGender: GenderEnum = .male
    if let selectedButton = self.genderButtons.filter({ $0.isSelected }).first {
      switch selectedButton.tag {
      case 0:
        friendsGender = .female
      case 1:
        friendsGender = .male
      case 2:
        friendsGender = .nonbinary
      default:
        print("Unknown button selected")
        return
      }
    } else {
      self.alert(title: "Missing Info", message: "You must fill out your friend's gender")
      return
    }
    
    guard let friendPromptInputVC = OnboardingFriendPromptInputViewController
      .instantiate(friendFirstName: friendFirstName, gender: friendsGender) else {
      print("Failed to instantiate friend info VC")
      return
    }
    self.navigationController?.pushViewController(friendPromptInputVC, animated: true)

  }
  
  @objc func genderButtonClicked(_ sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.genderButtons.forEach({ $0.isSelected = false})
    sender.isSelected = true
    self.genderButtons.forEach({
      if $0.isSelected {
        $0.backgroundColor = R.color.primaryBrandColor()
      } else {
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
      }
    })
  }
  
}

// MARK: - Life Cycle
extension OnboardingFriendNameViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
    self.setPreviousPageProgress()
    self.addKeyboardDismissOnTap()
    self.addKeyboardNotifications(animated: true)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.setCurrentPageProgress(animated: animated)
  }
  
  func stylize() {
    self.titleLabel.stylizeOnboardingHeaderTitleLabel()
    self.continueButton.stylizeOnboardingContinueButton()
    self.genderButtons.forEach({
      $0.setTitleColor(R.color.primaryTextColor(), for: .normal)
      $0.setTitleColor(UIColor.white, for: .selected)
      $0.layer.cornerRadius = 20.0
      $0.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
      if let font = R.font.openSansBold(size: 14.0) {
        $0.titleLabel?.font = font
      }
    })
  }
  
  func setup() {
    guard let firstNameInputVC = SimpleFieldInputViewController.instantiate(fieldName: "Their first name is...",
                                                                            previousValue: nil,
                                                                            placeholder: "Enter their first name",
                                                                            visibility: true) else {
                                                                              print("Unable to instantiate Simple Field Input VC")
                                                                              return
    }
    self.firstNameVC = firstNameInputVC
    self.addChild(firstNameInputVC)
    self.stackView.addSpacer(height: 10)
    self.stackView.addArrangedSubview(firstNameInputVC.view)
    firstNameInputVC.didMove(toParent: self)
    firstNameInputVC.inputTextField.textContentType = .givenName
    firstNameInputVC.inputTextField.autocapitalizationType = .words
    
    self.stackView.addSpacer(height: 10)
    let containerView = UIView()
    let titleLabel = UILabel()
    titleLabel.text = "Their gender is..."
    titleLabel.textColor = R.color.primaryTextColor()
    if let font = R.font.openSansBold(size: 14.0) {
      titleLabel.font = font
    }
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(titleLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: 20.0),
      NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -20.0),
      NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 4.0)
      ])
    
    let femaleButton = UIButton()

    femaleButton.setTitle("Female", for: .normal)
    femaleButton.translatesAutoresizingMaskIntoConstraints = false
    femaleButton.addConstraint(NSLayoutConstraint(item: femaleButton, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 45))
    containerView.addSubview(femaleButton)
    
    let maleButton = UIButton()
    maleButton.tag = 1
    maleButton.setTitle("Male", for: .normal)
    maleButton.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(maleButton)
    
    let nonbinaryButton = UIButton()
    nonbinaryButton.tag = 1
    nonbinaryButton.setTitle("Non Binary", for: .normal)
    nonbinaryButton.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(nonbinaryButton)
    
    // Adds position button constraints
    containerView.addConstraints([
      NSLayoutConstraint(item: femaleButton, attribute: .top, relatedBy: .equal,
                         toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 8.0),
      NSLayoutConstraint(item: femaleButton, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -8.0),
      NSLayoutConstraint(item: femaleButton, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: 20.0),
      NSLayoutConstraint(item: nonbinaryButton, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -20.0)
      ])
    
    // Adds relative button constraints
    containerView.addConstraints([
      NSLayoutConstraint(item: femaleButton, attribute: .width, relatedBy: .equal,
                         toItem: maleButton, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: femaleButton, attribute: .height, relatedBy: .equal,
                         toItem: maleButton, attribute: .height, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: femaleButton, attribute: .centerY, relatedBy: .equal,
                         toItem: maleButton, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: femaleButton, attribute: .width, relatedBy: .equal,
                         toItem: nonbinaryButton, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: femaleButton, attribute: .height, relatedBy: .equal,
                         toItem: nonbinaryButton, attribute: .height, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: femaleButton, attribute: .centerY, relatedBy: .equal,
                         toItem: nonbinaryButton, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: femaleButton, attribute: .right, relatedBy: .equal,
                         toItem: maleButton, attribute: .left, multiplier: 1.0, constant: -12.0),
      NSLayoutConstraint(item: maleButton, attribute: .right, relatedBy: .equal,
                         toItem: nonbinaryButton, attribute: .left, multiplier: 1.0, constant: -12.0)
      ])
    
    self.genderButtons = [femaleButton, maleButton, nonbinaryButton]
    self.genderButtons.forEach({
      $0.addTarget(self, action: #selector(OnboardingFriendNameViewController.genderButtonClicked(_:)), for: .touchUpInside)
    })
    
    self.stackView.addArrangedSubview(containerView)
    
  }
  
}

// MARK: - Progress Bar Protocol
extension OnboardingFriendNameViewController: ProgressBarProtocol {
  var progressWidthConstraint: NSLayoutConstraint {
    return progressBarWidthConstraint
  }
  
  var progressBarCurrentPage: Int {
    return 2
  }
  
  var progressBarTotalPages: Int {
    return 3
  }
}

// MARK: - KeyboardEventsBottomProtocol
extension OnboardingFriendNameViewController: KeyboardEventsBottomProtocol {
  var bottomKeyboardConstraint: NSLayoutConstraint? {
    return self.continueButtonBottomConstraint
  }
  
  var bottomKeyboardPadding: CGFloat {
    return 20.0
  }
}

// MARK: - KeyboardEventsDismissTapProtocol
extension OnboardingFriendNameViewController: KeyboardEventsDismissTapProtocol {
  func addKeyboardDismissOnTap() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OnboardingFriendNameViewController.backgroundViewTapped)))
  }

  @objc func backgroundViewTapped() {
    self.dismissKeyboard()
  }
}
