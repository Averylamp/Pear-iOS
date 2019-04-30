//
//  UserNameInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import MessageUI
import FirebaseAnalytics

class UserNameInputViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var nameFieldContainer: UIView!
  
  var profileData: ProfileCreationData!
  var activityIndicator = NVActivityIndicatorView(frame: CGRect.zero)
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(profileCreationData: ProfileCreationData) -> UserNameInputViewController? {
    guard let userNameVC = R.storyboard.userNameInputViewController()
      .instantiateInitialViewController() as? UserNameInputViewController else { return nil }
    userNameVC.profileData = profileCreationData
    return userNameVC
  }
  
  @IBAction func continueButtonClicked(_ sender: Any) {
    if let name = self.nameTextField.text, name.count > 2 {
      guard let userID = DataStore.shared.currentPearUser?.documentID else {
        print("No documentID Found")
        return
      }
      DataStore.shared.currentPearUser?.firstName = name
      self.profileData.updateAuthor(authorID: userID, authorFirstName: name)
      self.updateUserName()
      self.promptMessageComposer()
    } else {
      
    }
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    let alertController = UIAlertController(title: "Delete profile?", message: "Your progress will not be saved", preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
      DispatchQueue.main.async {
        self.navigationController?.popToRootViewController(animated: true)
      }
    }
    alertController.addAction(alertAction)
    alertController.addAction(deleteAction)
    self.present(alertController, animated: true, completion: nil)  }
  
  func updateUserName() {
    if let firstName = self.nameTextField.text {
      guard let userID = DataStore.shared.currentPearUser?.documentID else {
        print("Failed to get Current User")
        return
      }
      PearUserAPI.shared.updateUserFirstName(userID: userID, firstName: firstName) { (result) in
                                            switch result {
                                            case .success(let successful):
                                              if successful {
                                                print("Update user first name was successful")
                                              } else {
                                                print("Update user first name was unsuccessful")
                                              }
                                              
                                            case .failure(let error):
                                              print("Update user failure: \(error)")
                                            }
        DataStore.shared.refreshPearUser(completion: nil)
      }
    }
    Analytics.logEvent("CP_firstName_DONE", parameters: nil)
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
      self.createDetachedProfile()
      return
      #endif
      
      if MFMessageComposeViewController.canSendText() {
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        
        messageVC.recipients = [phoneNumber]
        if profileData.roasts.count > 0 {
          messageVC.body = "I just roasted you on getpear.com! 🍐 https://getpear.com/go/refer"
        } else {
          messageVC.body = "I just boasted you on getpear.com! 🍐 https://getpear.com/go/refer"
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
  
  func continueToSMSCanceledPage() {
    DispatchQueue.main.async {
      guard let smsCancledVC = SMSCanceledViewController.instantiate(profileCreationData: self.profileData) else {
        print("Failed to create SMS Cancelled VC")
        return
      }
      self.navigationController?.pushViewController(smsCancledVC, animated: true)
    }
  }
  
  func createDetachedProfile() {
    PearProfileAPI.shared.createNewDetachedProfile(profileCreationData: self.profileData) { (result) in
      switch result {
      case .success(let detachedProfile):
        Analytics.logEvent("CP_SUCCESS", parameters: nil)
        print(detachedProfile)
        DataStore.shared.reloadAllUserData()
        DispatchQueue.main.async {
          guard let profileFinishedVC = ProfileCreationFinishedViewController.instantiate() else {
            print("Failed to create Profile Finished VC")
            return
          }
          self.navigationController?.setViewControllers([profileFinishedVC], animated: true)
        }
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

// MARK: - Life Cycle
extension UserNameInputViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.nameTextField.becomeFirstResponder()
  }
  
  func stylize() {
    self.view.backgroundColor = R.color.backgroundColorOrange()
    if let font = R.font.openSansExtraBold(size: 16) {
      self.titleLabel.font = font
    }
    self.titleLabel.textColor = UIColor.white
    self.nameTextField.tintColor = UIColor.black
    self.continueButton.layer.cornerRadius = self.continueButton.frame.height / 2.0
    self.continueButton.setTitleColor(UIColor.black, for: .normal)
    self.continueButton.backgroundColor = R.color.backgroundColorYellow()
    self.nameFieldContainer.layer.cornerRadius = 12
    
  }
  
}

// MARK: - Dismiss First Responder on Click
extension UserNameInputViewController {
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserNameInputViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.view.endEditing(true)
  }
}

extension UserNameInputViewController: MFMessageComposeViewControllerDelegate {
  
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
      self.continueToSMSCanceledPage()
    case .failed:
      self.dismissMessageVC(controller: controller)
      self.continueToSMSCanceledPage()
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
