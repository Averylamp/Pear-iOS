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
  @IBOutlet weak var stackView: UIStackView!
  
  @IBOutlet weak var relationshipButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
  
  var genderButtons: [UIButton] = []
  var ageRangeVC: AgeRangeInputViewController?
  
  let initializationTime: Double = CACurrentMediaTime()

  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingPreferencesViewController? {
    guard let onboardingFriendNameVC = R.storyboard.onboardingPreferencesViewController
      .instantiateInitialViewController()  else { return nil }
    return onboardingFriendNameVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    SlackHelper.shared.addEvent(text: "User went back from User Preferences VC in \(round((CACurrentMediaTime() - self.initializationTime) * 100) / 100)s", color: UIColor.red)
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.updateUserPreferences()
    self.updateUserSeeking(seeking: true)
    self.continueToPicturesVC()
  }
  
  @IBAction func relationshipButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.updateUserPreferences()
    self.updateUserSeeking(seeking: false)
    self.continueToPicturesVC()
  }
  
  func continueToPicturesVC() {
    guard let picturesVC = OnboardingPicturesViewController.instantiate() else {
      print("Failed to instantiate pictures VC")
      return
    }
    SlackHelper.shared.addEvent(text: "Continuing to User Pictures VC in \(round((CACurrentMediaTime() - self.initializationTime) * 100) / 100)s.)", color: UIColor.green)
    self.navigationController?.pushViewController(picturesVC, animated: true)
  }
  
  @objc func genderButtonClicked(_ sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    sender.isSelected = !sender.isSelected
    self.genderButtons.forEach({
      if $0.isSelected {
        $0.backgroundColor = R.color.primaryBrandColor()
      } else {
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
      }
    })
  }
  
  func updateUserPreferences() {
    var seekingGenders: [GenderEnum] = []
    self.genderButtons.filter({$0.isSelected}).forEach({
      switch $0.tag {
      case 0:
        seekingGenders.append(.female)
      case 1:
        seekingGenders.append(.male)
      case 2:
        seekingGenders.append(.nonbinary)
      default:
        break
      }
    })
    guard let minAge = self.ageRangeVC?.minAge,
      let maxAge = self.ageRangeVC?.maxAge else {
      print("Unable to get age range")
        return
    }
    DataStore.shared.currentPearUser?.matchingPreferences.seekingGender = seekingGenders
    DataStore.shared.currentPearUser?.matchingPreferences.minAgeRange = minAge
    DataStore.shared.currentPearUser?.matchingPreferences.maxAgeRange = maxAge
    SlackHelper.shared.addEvent(text: "User Picked Preferences, gender(s): \(seekingGenders.map({ $0.toString() }).joined(separator: ", ")), minAge: \(minAge), maxAge: \(maxAge) in \(round((CACurrentMediaTime() - self.initializationTime) * 100) / 100)s.)", color: UIColor.blue)
    PearUpdateUserAPI.shared.updateUserMatchingPreferences(seekingGenders: seekingGenders,
                                                           minAge: minAge, maxAge: maxAge) { (result) in
                                                            switch result {
                                                            case .success(let successful):
                                                              if successful {
                                                                print("Successfully update user preferences")
                                                              } else {
                                                                print("Failed to update user preferences")
                                                              }
                                                            case .failure(let error):
                                                              print("Failed to update user preferences: \(error)")
                                                            }
    }
  }
  
  func updateUserSeeking(seeking: Bool) {
    DataStore.shared.currentPearUser?.isSeeking = seeking
    SlackHelper.shared.addEvent(text: "User Picked Preferences, seeking: \(seeking) in \(round((CACurrentMediaTime() - self.initializationTime) * 100) / 100)s.)", color: UIColor.blue)
    PearUpdateUserAPI.shared.updateUserIsSeeking(seeking: seeking) { (result) in
      switch result {
      case .success(let successful):
        if successful {
          print("Successfully update user seeking \(seeking)")
        } else {
          print("Failed to update user seeking \(seeking)")
        }
      case .failure(let error):
        print("Failed to update user seeking \(seeking): \(error)")
      }
    }
  }
  
}

// MARK: - Life Cycle
extension OnboardingPreferencesViewController {
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
    self.relationshipButton.stylizeOnboardingContinueButton()
    self.relationshipButton.backgroundColor = UIColor(white: 0.87, alpha: 1.0)
    self.relationshipButton.setTitleColor(UIColor(white: 0.6, alpha: 1.0), for: .normal)
    self.genderButtons.forEach({
      $0.setTitleColor(R.color.primaryTextColor(), for: .normal)
      $0.setTitleColor(UIColor.white, for: .selected)
      $0.layer.cornerRadius = 20.0
      if $0.isSelected {
        $0.backgroundColor = R.color.primaryBrandColor()
      } else {
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
      }
      if let font = R.font.openSansBold(size: 14.0) {
        $0.titleLabel?.font = font
      }
    })

  }
  
  func setup() {
    self.addGenderButtons()
    self.addAgeRange()
  }
  
  func addGenderButtons() {
    self.stackView.addSpacer(height: 10)
    let containerView = UIView()
    let titleLabel = UILabel()
    titleLabel.text = "Seeking Gender"
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
    nonbinaryButton.tag = 2
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
      $0.addTarget(self, action: #selector(OnboardingPreferencesViewController.genderButtonClicked(_:)), for: .touchUpInside)
    })
    if let seekingGenders = DataStore.shared.currentPearUser?.matchingPreferences.seekingGender {
      if seekingGenders.count != 3 {
        seekingGenders.forEach({
          switch $0 {
          case .female:
            femaleButton.isSelected = true
          case .male:
            maleButton.isSelected = true
          case .nonbinary:
            nonbinaryButton.isSelected = true
          }
        })
      }
      if seekingGenders.count == 0 || seekingGenders.count == 3,
        let currentGender = DataStore.shared.currentPearUser?.gender {
        switch currentGender {
        case .male:
          femaleButton.isSelected = true
        case .female:
          maleButton.isSelected = true
        case .nonbinary:
          maleButton.isSelected = true
          femaleButton.isSelected = true
        }
      }
    }
    
    self.stackView.addArrangedSubview(containerView)
  }
  
  func addAgeRange() {
    self.stackView.addSpacer(height: 10)
    let containerView = UIView()
    let titleLabel = UILabel()
    titleLabel.text = "Age Range"
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
    var defaultMin: Int = 18
    var defaultMax: Int = 25
    if let currentAge = DataStore.shared.currentPearUser?.age {
      defaultMin = max(18, currentAge - 4)
      defaultMax = min(80, currentAge + 4)
    }
    if let previousMin = DataStore.shared.currentPearUser?.matchingPreferences.minAgeRange {
      defaultMin = previousMin
    }
    if let previousMax = DataStore.shared.currentPearUser?.matchingPreferences.maxAgeRange {
      defaultMax = previousMax
    }
    guard let ageRangeInputVC = AgeRangeInputViewController.instantiate(minAge: defaultMin, maxAge: defaultMax) else {
      print("Unable to create age range input VC")
      return
    }
    self.ageRangeVC = ageRangeInputVC
    self.addChild(ageRangeInputVC)
    ageRangeInputVC.view.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.addSubview(ageRangeInputVC.view)
    containerView.addConstraints([
      NSLayoutConstraint(item: ageRangeInputVC.view as Any, attribute: .top, relatedBy: .equal,
                         toItem: titleLabel, attribute: .top, multiplier: 1.0, constant: 4.0),
      NSLayoutConstraint(item: ageRangeInputVC.view as Any, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: ageRangeInputVC.view as Any, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: ageRangeInputVC.view as Any, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -4.0)
      ])
    ageRangeInputVC.didMove(toParent: self)
    self.stackView.addArrangedSubview(containerView)
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

// MARK: - KeyboardEventsDismissTapProtocol
extension OnboardingPreferencesViewController: KeyboardEventsDismissTapProtocol {
  func addKeyboardDismissOnTap() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OnboardingPreferencesViewController.backgroundViewTapped)))
  }
  
  @objc func backgroundViewTapped() {
    self.dismissKeyboard()
  }
}
