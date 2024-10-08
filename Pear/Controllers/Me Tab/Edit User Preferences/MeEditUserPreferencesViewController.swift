//
//  MeEditUserViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/6/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class MeEditUserPreferencesViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  
  var genderButtons: [UIButton] = []
  var ageRangeVC: AgeRangeInputViewController?
  var seekingSwitch: UISwitch?
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> MeEditUserPreferencesViewController? {
    guard let userPreferencesVC = R.storyboard.meEditUserPreferencesViewController
      .instantiateInitialViewController()  else { return nil }
    return userPreferencesVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.updateUserPreferences()
    if let seeking = self.seekingSwitch?.isOn {
      self.updateUserSeeking(seeking: seeking)
    }
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.updateUserPreferences()
    if let seeking = self.seekingSwitch?.isOn {
      self.updateUserSeeking(seeking: seeking)
    }
    self.navigationController?.popViewController(animated: true)
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
    PearUpdateUserAPI.shared.updateUserMatchingPreferences(seekingGenders: seekingGenders,
                                                           minAge: minAge, maxAge: maxAge) { (result) in
                                                            switch result {
                                                            case .success(let successful):
                                                              if successful {
                                                                print("Successfully update user preferences")
                                                                // refresh discovery feed if browsing for self and preferences updated
                                                                if let user = DataStore.shared.currentPearUser {
                                                                  // TODO(@averylamp): Fix Discovery Refresh on Pref changes
                                                                  if DataStore.shared.getCurrentFilters().userID == user.documentID {
                                                                    NotificationCenter.default.post(name: .refreshDiscoveryFeed, object: nil)
                                                                  }
                                                                }
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
extension MeEditUserPreferencesViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
    self.addKeyboardDismissOnTap()
  }
  
  func stylize() {
    self.titleLabel.stylizeOnboardingHeaderTitleLabel()
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
    self.addSeeking()
  }
  
  func addGenderButtons() {
    self.stackView.addSpacer(height: 10)
    self.stackView.addTitleLabel(text: "Seeking Gender")
    let containerView = UIView()
    
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
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 4.0),
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
    
    self.stackView.addArrangedSubview(containerView)
  }
  
  func addAgeRange() {
    self.stackView.addSpacer(height: 10)
    self.stackView.addTitleLabel(text: "Age Range")
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
  
  func addSeeking() {
    self.stackView.addSpacer(height: 20.0)
    guard let seeking = DataStore.shared.currentPearUser?.isSeeking else {
      print("Unable to determine if seeking")
      return
    }
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    let seekingLabel = UILabel()
    seekingLabel.translatesAutoresizingMaskIntoConstraints = false
    seekingLabel.text = "Seeking?"
    if let font = R.font.openSansBold(size: 16) {
      seekingLabel.font = font
    }
    seekingLabel.textColor = R.color.primaryTextColor()
    containerView.addSubview(seekingLabel)
    
    let seekingSwitch = UISwitch()
    seekingSwitch.translatesAutoresizingMaskIntoConstraints = false
    self.seekingSwitch = seekingSwitch
    seekingSwitch.tintColor = R.color.primaryBrandColor()
    seekingSwitch.isOn = seeking
    containerView.addSubview(seekingSwitch)
    
    containerView.addConstraints([
      NSLayoutConstraint(item: seekingLabel, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: seekingLabel, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 4.0),
      NSLayoutConstraint(item: seekingLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -4.0),
      NSLayoutConstraint(item: seekingLabel, attribute: .right, relatedBy: .equal,
                         toItem: seekingSwitch, attribute: .left, multiplier: 1.0, constant: -8.0),
      NSLayoutConstraint(item: seekingLabel, attribute: .centerY, relatedBy: .equal,
                         toItem: seekingSwitch, attribute: .centerY, multiplier: 1.0, constant: 0.0)
//      NSLayoutConstraint(item: seekingSwitch, attribute: .right, relatedBy: .equal,
//                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -12.0)
      ])
    
    self.stackView.addArrangedSubview(containerView)
  }
  
}

// MARK: - KeyboardEventsDismissTapProtocol
extension MeEditUserPreferencesViewController: KeyboardEventsDismissTapProtocol {
  func addKeyboardDismissOnTap() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MeEditUserPreferencesViewController.backgroundViewTapped)))
  }
  
  @objc func backgroundViewTapped() {
    self.dismissKeyboard()
  }
}
