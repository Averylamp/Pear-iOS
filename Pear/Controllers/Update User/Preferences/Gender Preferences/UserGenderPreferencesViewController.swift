//
//  UserGenderPreferencesViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/2/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserGenderPreferencesViewController: UpdateUIViewController {

  private var initialGenderPreferences: [GenderEnum] = []
  var genderPreferences: [GenderEnum] = []
  
  @IBOutlet weak var maleGenderButton: UIButton!
  @IBOutlet weak var femaleGenderButton: UIButton!
  @IBOutlet weak var nonbinaryGenderButton: UIButton!
  @IBOutlet weak var maleSelectedIndicator: UIImageView!
  @IBOutlet weak var femaleSelectedIndicator: UIImageView!
  @IBOutlet weak var nonbinarySelectedIndicator: UIImageView!
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(genderPreferences: [GenderEnum]) -> UserGenderPreferencesViewController? {
    let storyboard = UIStoryboard(name: String(describing: UserGenderPreferencesViewController.self), bundle: nil)
    guard let genderPreferencesVC = storyboard.instantiateInitialViewController() as? UserGenderPreferencesViewController else { return nil }
    genderPreferencesVC.genderPreferences = genderPreferences
    genderPreferencesVC.initialGenderPreferences = genderPreferences
    return genderPreferencesVC
  }
  
  override func didMakeUpdates() -> Bool {
    if initialGenderPreferences.count != genderPreferences.count {
      return true
    }
    for genderPref in initialGenderPreferences where !genderPreferences.contains(genderPref) {
      return true
    }
    return false
  }
  
  @IBAction func genderButtonToggled(_ sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    switch sender {
    case self.maleGenderButton:
      if let index = genderPreferences.firstIndex(of: .male) {
        genderPreferences.remove(at: index)
      } else {
        genderPreferences.append(.male)
      }
    case self.femaleGenderButton:
      if let index = genderPreferences.firstIndex(of: .female) {
        genderPreferences.remove(at: index)
      } else {
        genderPreferences.append(.female)
      }
    case self.nonbinaryGenderButton:
      if let index = genderPreferences.firstIndex(of: .nonbinary) {
        genderPreferences.remove(at: index)
      } else {
        genderPreferences.append(.nonbinary)
      }
    default:
      break
    }
    
    self.stylizeGenderButtons()
  }
  
}

// MARK: - Life Cycle
extension UserGenderPreferencesViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.stylizeGenderButtons()
  }
  
  func stylize() {
    self.titleLabel.stylizePreferencesTitleLabel()
    self.subtitleLabel.stylizePreferencesSubtitleLabel()
  }
  
  func stylizeGenderButtons() {
    print(self.genderPreferences)
    if self.genderPreferences.contains(.male) {
      self.maleGenderButton.stylizeLightSelected()
      self.maleSelectedIndicator.isHidden = false
    } else {
      self.maleGenderButton.stylizeLight()
      self.maleSelectedIndicator.isHidden = true
    }
    
    if self.genderPreferences.contains(.female) {
      self.femaleGenderButton.stylizeLightSelected()
      self.femaleSelectedIndicator.isHidden = false
    } else {
      self.femaleGenderButton.stylizeLight()
      self.femaleSelectedIndicator.isHidden = true
    }
    
    if self.genderPreferences.contains(.nonbinary) {
      self.nonbinaryGenderButton.stylizeLightSelected()
      self.nonbinarySelectedIndicator.isHidden = false
    } else {
      self.nonbinaryGenderButton.stylizeLight()
      self.nonbinarySelectedIndicator.isHidden = true
    }
  }
  
}
