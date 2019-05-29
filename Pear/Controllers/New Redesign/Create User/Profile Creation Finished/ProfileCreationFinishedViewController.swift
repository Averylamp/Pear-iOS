//
//  ProfileCreationFinishedViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import ContactsUI

class ProfileCreationFinishedViewController: UIViewController {

  @IBOutlet weak var makeAnotherButton: UIButton!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> ProfileCreationFinishedViewController? {
    guard let profileVibeVC = R.storyboard.profileCreationFinishedViewController
      .instantiateInitialViewController() else { return nil }
    return profileVibeVC
  }
  
  @IBAction func makeAnotherButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    Analytics.logEvent("CP_postCreation_TAP_createAnother", parameters: nil)
    self.promptContactsPicker()
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
    Analytics.logEvent("CP_postCreation_TAP_continue", parameters: nil)
    guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
      print("Failed to create main VC")
      return
    }
    self.navigationController?.setViewControllers([mainVC], animated: true)
  }
  
}

// MARK: - Life Cycle
extension ProfileCreationFinishedViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    self.view.backgroundColor = R.color.backgroundColorPurple()
    if let font = R.font.openSansExtraBold(size: 16) {
      self.titleLabel.font = font
    }
    self.titleLabel.textColor = UIColor.white
    if let font = R.font.openSansExtraBold(size: 18) {
      self.makeAnotherButton.titleLabel?.font = font
      self.continueButton.titleLabel?.font = font
    }
    self.makeAnotherButton.setTitleColor(UIColor.black, for: .normal)
    self.makeAnotherButton.layer.cornerRadius = self.makeAnotherButton.frame.height / 2.0
    self.makeAnotherButton.backgroundColor = R.color.backgroundColorYellow()
    self.continueButton.setTitleColor(UIColor.black, for: .normal)
    self.continueButton.layer.cornerRadius = self.continueButton.frame.height / 2.0
    self.continueButton.backgroundColor = UIColor(red: 0.79, green: 0.74, blue: 1.00, alpha: 1.00)
    
  }
  
}

// MARK: ProfileCreationProtocol
extension ProfileCreationFinishedViewController: ProfileCreationProtocol, CNContactPickerDelegate {
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    self.didSelectContact(contact: contact)
  }
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
    self.didSelectContactProperty(contactProperty: contactProperty)
  }
  
  func receivedProfileCreationData(creationData: ProfileCreationData) {
    DispatchQueue.main.async {
      guard let vibesVC = ProfileInputVibeViewController.instantiate(profileCreationData: creationData) else {
        print("Failed to create Vibes VC")
        return
      }
      self.navigationController?.pushViewController(vibesVC, animated: true)
    }
  }
  
  func recievedProfileCreationError(title: String, message: String?) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(alert, animated: true)
    }
  }
  
  func promptContactsPicker() {
    let cnPicker = self.getContactsPicker()
    cnPicker.delegate = self
    self.present(cnPicker, animated: true, completion: nil)
  }
  
}
