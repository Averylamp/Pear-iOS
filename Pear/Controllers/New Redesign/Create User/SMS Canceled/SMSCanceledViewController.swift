//
//  SMSCanceledViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/29/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import MessageUI
import FirebaseAnalytics

class SMSCanceledViewController: UIViewController {
  
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var skipButton: UIButton!
  
  var profileData: ProfileCreationData!
  var activityIndicator = NVActivityIndicatorView(frame: CGRect.zero)
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(profileCreationData: ProfileCreationData) -> SMSCanceledViewController? {
    guard let smsCancelledVC = R.storyboard.smsCanceledViewController
      .instantiateInitialViewController() else { return nil }
    smsCancelledVC.profileData = profileCreationData
    return smsCancelledVC
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    self.promptMessageComposer()
  }
  @IBAction func skipButtonClicked(_ sender: Any) {
    self.createDetachedProfile(profileData: self.profileData,
                               completion: self.createDetachedProfileCompletion(result:))
  }
  
}

// MARK: - Life Cycle
extension SMSCanceledViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
   self.stylize()
  }
  
  func stylize() {
    
    self.continueButton.layer.cornerRadius = self.continueButton.frame.height / 2.0
    self.continueButton.setTitleColor(UIColor.white, for: .normal)
    self.continueButton.backgroundColor = R.color.backgroundColorPurple()
    self.skipButton.layer.cornerRadius = self.continueButton.frame.height / 2.0
    self.skipButton.setTitleColor(UIColor.black, for: .normal)
    self.skipButton.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.00)

  }
  
  func promptMessageComposer() {
    guard let messageVC = self.getMessageComposer(profileData: self.profileData) else {
      print("Could not create Message VC")
      Analytics.logEvent("CP_sendProfileSMS_FAIL", parameters: nil)
      self.createDetachedProfile(profileData: self.profileData,
                                 completion: self.createDetachedProfileCompletion(result:))
      return
    }
    messageVC.messageComposeDelegate = self
    #if DEVMODE
//    self.createDetachedProfile(profileData: self.profileData,
//                               completion: self.createDetachedProfileCompletion(result:))
//    return
    #endif
    
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
    self.present(messageVC, animated: true, completion: nil)
    Analytics.logEvent("CP_sendProfileSMS_START", parameters: nil)
  }
  
  func createDetachedProfileCompletion(result: Result<PearDetachedProfile, (errorTitle: String, errorMessage: String)?>) {
    switch result {
    case .success:
      DispatchQueue.main.async {
        guard let profileFinishedVC = ProfileCreationFinishedViewController.instantiate() else {
          print("Failed to create Profile Finished VC")
          return
        }
        self.navigationController?.setViewControllers([profileFinishedVC], animated: true)
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
  
}

// MARK: - PromptSMSProtocol
extension SMSCanceledViewController: PromptSMSProtocol {
  
}

// MARK: - MFMessageComposeViewControllerDelegate
extension SMSCanceledViewController: MFMessageComposeViewControllerDelegate {
  
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
    case .cancelled:
      self.dismissMessageVC(controller: controller)
    case .failed:
      self.dismissMessageVC(controller: controller)
    case .sent:
      controller.dismiss(animated: true) {
        DispatchQueue.main.async {
          self.createDetachedProfile(profileData: self.profileData,
                                     completion: self.createDetachedProfileCompletion(result:))
        }
      }
    @unknown default:
      fatalError()
    }
  }
}
