//
//  OnboardingFriendInfoViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import MessageUI
import FirebaseAnalytics
import ContactsUI

class OnboardingFriendInfoViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet var labelGroup: [UILabel]!
  @IBOutlet var headerLabelGroup: [UILabel]!
  
  @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
  
  var friendFirstName: String!
  var friendGender: GenderEnum!
  var profileData: ProfileCreationData?
  var activityIndicator = NVActivityIndicatorView(frame: CGRect.zero)
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(friendFirstName: String, friendGender: GenderEnum) -> OnboardingFriendInfoViewController? {
    guard let onboardingFriendInfoVC = R.storyboard.onboardingFriendInfoViewController()
      .instantiateInitialViewController() as? OnboardingFriendInfoViewController else { return nil }
    onboardingFriendInfoVC.friendFirstName = friendFirstName
    onboardingFriendInfoVC.friendGender = friendGender
    return onboardingFriendInfoVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.promptContactsPicker()
  }
  
  func promptMessageComposer() {
    print("****prompting message composer****")
    guard let profileData = self.profileData else {
      print("profile data not found")
      return
    }
    guard let messageVC = self.getMessageComposer(profileData: profileData) else {
      print("Could not create Message VC")
      Analytics.logEvent("CP_sendProfileSMS_FAIL", parameters: nil)
      self.createDetachedProfile(profileData: profileData,
                                 completion: self.createDetachedProfileCompletion(result:))
      return
    }
    messageVC.messageComposeDelegate = self
    // #if DEVMODE
    // self.createDetachedProfile(profileData: profileData,
    //                            completion: self.createDetachedProfileCompletion(result:))
    // return
    // #endif
    self.present(messageVC, animated: true, completion: nil)
    Analytics.logEvent("CP_sendProfileSMS_START", parameters: nil)
  }
  
}

// MARK: - Life Cycle
extension OnboardingFriendInfoViewController {
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
    if UIScreen.main.bounds.width <= 320 {
      labelGroup.forEach {
        if let font = R.font.openSansSemiBold(size: 13) {
          $0.font = font
        }
      }
      headerLabelGroup.forEach {
        if let font = R.font.openSansBold(size: 16) {
          $0.font = font
        }
      }
    }
  }
  
  func setup() {
    
  }
  
}

// MARK: - Progress Bar Protocol
extension OnboardingFriendInfoViewController: ProgressBarProtocol {
  var progressWidthConstraint: NSLayoutConstraint {
    return progressBarWidthConstraint
  }
  
  var progressBarCurrentPage: Int {
    return 2
  }
  
  var progressBarTotalPages: Int {
    return 2
  }
}

// MARK: - PromptSMSProtocol
extension OnboardingFriendInfoViewController: PromptSMSProtocol {
  
}

extension OnboardingFriendInfoViewController: ProfileCreationProtocol, CNContactPickerDelegate {
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    self.didSelectContact(contact: contact)
    picker.dismiss(animated: true)
  }
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
    self.didSelectContactProperty(contactProperty: contactProperty)
    picker.dismiss(animated: true)
  }
  
  func receivedProfileCreationData(creationData: ProfileCreationData) {
    self.profileData = creationData
    self.profileData?.firstName = self.friendFirstName
    self.profileData?.gender = self.friendGender
    DispatchQueue.main.async {
      self.promptMessageComposer()
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
    
    self.continueButton.isEnabled = false
    self.activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                                     type: NVActivityIndicatorType.lineScalePulseOut,
                                                     color: StylingConfig.textFontColor,
                                                     padding: 0)
    self.view.addSubview(activityIndicator)
    activityIndicator.center = CGPoint(x: self.view.center.x,
                                       y: self.continueButton.frame.origin.y +
                                        self.continueButton.frame.height + 40)
    activityIndicator.startAnimating()
    self.present(cnPicker, animated: true, completion: nil)
  }
  
}

// MARK: - MFMessageComposeViewControllerDelegate
extension OnboardingFriendInfoViewController: MFMessageComposeViewControllerDelegate {
  func createDetachedProfileCompletion(result: Result<PearDetachedProfile, (errorTitle: String, errorMessage: String)?>) {
    switch result {
    case .success:
      DispatchQueue.main.async {
        guard let basicInfoVC = OnboardingBasicInfoViewController.instantiate() else {
          print("Failed to create basic info VC")
          return
        }
        self.navigationController?.setViewControllers([basicInfoVC], animated: true)
      }
    case .failure(let error):
      if let error = error {
        DispatchQueue.main.async {
          self.alert(title: error.errorTitle, message: error.errorMessage)
        }
      }
    }
    DispatchQueue.main.async {
      self.activityIndicator.stopAnimating()
      self.continueButton.isEnabled = true
    }
  }
  
  func dismissMessageVC(controller: MFMessageComposeViewController) {
    controller.dismiss(animated: true) {
      DispatchQueue.main.async {
        self.continueButton.isEnabled = true
        self.activityIndicator.stopAnimating()
      }
    }
  }
  
  func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    switch result {
    case .cancelled, .failed:
      self.dismissMessageVC(controller: controller)
    case .sent:
      controller.dismiss(animated: true) {
        if let profileData = self.profileData {
          DispatchQueue.main.async {
            self.createDetachedProfile(profileData: profileData,
                                       completion: self.createDetachedProfileCompletion(result:))
          }
        } else {
          print("couldn't find profile data")
        }
      }
    @unknown default:
      fatalError()
    }
  }
}
