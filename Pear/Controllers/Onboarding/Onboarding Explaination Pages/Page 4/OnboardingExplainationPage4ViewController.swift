//
//  OnboardingExplainationPage1ViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import ContactsUI

class OnboardingExplainationPage4ViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var memeImageView: UIImageView!
  
  @IBOutlet weak var joinWithFriendButton: UIButton!
  @IBOutlet weak var joinBySelfButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OnboardingExplainationPage4ViewController? {
    guard let onboardingPage4VC = R.storyboard.onboardingExplainationPage4ViewController
      .instantiateInitialViewController()  else { return nil }
    
    return onboardingPage4VC
  }
  
  @IBAction func joinWithFriendClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.promptContactsPicker()
  }
  
  @IBAction func joinBySelfClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let basicInfoVC = OnboardingBasicInfoViewController.instantiate() else {
      print("Failed to create next Onboarding Info Page")
      return
    }
    self.navigationController?.pushViewController(basicInfoVC, animated: true)
  }
}

// MARK: - Life Cycle
extension OnboardingExplainationPage4ViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }

  func stylize() {
    self.titleLabel.stylizeOnboardingMemeTitleLabel()
    self.memeImageView.stylizeOnboardingMemeImage()
    self.joinWithFriendButton.stylizeOnboardingContinueButton()
    self.joinBySelfButton.stylizeOnboardingContinueButton()
    self.joinBySelfButton.backgroundColor = UIColor(white: 0.87, alpha: 1.0)
    self.joinBySelfButton.setTitleColor(UIColor(white: 0.6, alpha: 1.0), for: .normal)
  }
  
}

// MARK: ProfileCreationProtocol
extension OnboardingExplainationPage4ViewController: ProfileCreationProtocol, CNContactPickerDelegate {
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    self.didSelectContact(contact: contact)
  }
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
    self.didSelectContactProperty(contactProperty: contactProperty)
  }
  
  func receivedProfileCreationData(creationData: ProfileCreationData) {
    DispatchQueue.main.async {
      guard let friendInfoVC = OnboardingFriendInfoViewController.instantiate(profileData: creationData,
                                                                              titleLabelText: "Join with a friend") else {
                                                                                print("Unable to create friend Info VC")
                                                                                return
      }
      self.navigationController?.pushViewController(friendInfoVC, animated: true)
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
