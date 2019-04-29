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
    guard let smsCancelledVC = R.storyboard.smsCanceledViewController()
      .instantiateInitialViewController() as? SMSCanceledViewController else { return nil }
    smsCancelledVC.profileData = profileCreationData
    return smsCancelledVC
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    self.promptMessageComposer()
  }
  @IBAction func skipButtonClicked(_ sender: Any) {
    self.createDetachedProfile()
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
    let phoneNumber = profileData.phoneNumber.filter("0123456789".contains)
    if phoneNumber.count == 10 {
      print("Verifying phone number")
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
      
      #if DEVMODE
      //      self.createDetachedProfile()
      //      return
      #endif
      
      if MFMessageComposeViewController.canSendText() {
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        
        messageVC.recipients = [phoneNumber]
        if profileData.roasts.count > 0 {
          messageVC.body = "I just roasted on getpear.com 🍐! https://getpear.com/go/refer"
        } else {
          messageVC.body = "I just boasted on getpear.com 🍐! https://getpear.com/go/refer"
        }
        if let memeImage = R.image.inviteMeme(),
          let pngData = memeImage.pngData() {
          messageVC.addAttachmentData(pngData, typeIdentifier: "public.data", filename: "Image.png")
        }
        
        self.present(messageVC, animated: true, completion: nil)
        Analytics.logEvent("CP_sendProfileSMS_START", parameters: nil)
      } else {
        Analytics.logEvent("CP_sendProfileSMS_FAIL", parameters: nil)
        createDetachedProfile()
      }
    }
  }
  
  func goToProfileFinishedVC() {
    DispatchQueue.main.async {
      guard let profileFinishedVC = ProfileCreationFinishedViewController.instantiate() else {
        print("Failed to create Profile Finished VC")
        return
      }
      self.navigationController?.setViewControllers([profileFinishedVC], animated: true)
    }
  }
  
  func createDetachedProfile() {
    PearProfileAPI.shared.createNewDetachedProfile(profileCreationData: self.profileData) { (result) in
      switch result {
      case .success(let detachedProfile):
        Analytics.logEvent("CP_SUCCESS", parameters: nil)
        print(detachedProfile)
        DataStore.shared.reloadAllUserData()
        self.goToProfileFinishedVC()
      case .failure(let error):
        print(error)
        Analytics.logEvent("CP_FAIL", parameters: nil)
        DispatchQueue.main.async {
          switch error {
          case .graphQLError(let message):
            self.alert(title: "Failed to Create Profile", message: message)
          case .userNotLoggedIn:
            self.alert(title: "Please login first", message: "You muust be logged in to create profiles")
          default:
            self.alert(title: "Oopsie", message: "Our server made an oopsie woopsie.  Please try again or let us know and we will do our best to fix it ASAP (support@getpear.com)")
          }
          self.activityIndicator.stopAnimating()
        }
      }
      DispatchQueue.main.async {
        self.continueButton.isEnabled = true
      }
      
    }
  }
  
}

extension SMSCanceledViewController: MFMessageComposeViewControllerDelegate {
  
  func dismissMessageVC(controller: MFMessageComposeViewController) {
    controller.dismiss(animated: true) {
      DispatchQueue.main.async {
        self.alert(title: "Tell your friend",
                   message: "You must let your friend know of their profile, and they must accept it to continue")
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
          self.createDetachedProfile()
        }
      }
    @unknown default:
      fatalError()
    }
  }
}
