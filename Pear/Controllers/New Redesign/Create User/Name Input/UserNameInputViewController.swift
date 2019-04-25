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
      self.profileData.updateAuthor(authorID: userID, authorFirstName: name)
      self.updateUserName()
      self.promptMessageComposer()
    } else {
      
    }
  }
  
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
        messageVC.body = "I wrote something for you on Pear! Check it out 🍐 https://getpear.com/go/refer"
        
        self.present(messageVC, animated: true, completion: nil)
        Analytics.logEvent("CP_sendProfileSMS_START", parameters: nil)
      } else {
        Analytics.logEvent("CP_sendProfileSMS_FAIL", parameters: nil)
        createDetachedProfile()
      }
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
    //    PearProfileAPI.shared.createNewDetachedProfile(gettingStartedUserProfileData: self.gettingStartedData) { (result) in
    //      print("Create Detached Profile Called")
    //      switch result {
    //      case .success(let detachedProfile):
    //        Analytics.logEvent("CP_success", parameters: nil)
    //        print(detachedProfile)
    //        DataStore.shared.refreshEndorsedUsers(completion: nil)
    //        DataStore.shared.getNotificationAuthorizationStatus { status in
    //          if status == .notDetermined {
    //            DispatchQueue.main.async {
    //              guard let allowNotificationVC = GetStartedAllowNotificationsViewController.instantiate(friendName: self.gettingStartedData.firstName) else {
    //                print("Failed to create Allow Notifications VC")
    //                return
    //              }
    //              self.navigationController?.pushViewController(allowNotificationVC, animated: true)
    //            }
    //          } else {
    //            DispatchQueue.main.async {
    //              guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
    //                print("Failed to initialize main VC")
    //                return
    //              }
    //              self.navigationController?.setViewControllers([mainVC], animated: true)
    //            }
    //          }
    //        }
    //      case .failure(let error):
    //        print(error)
    //        DispatchQueue.main.async {
    //          switch error {
    //          case .graphQLError(let message):
    //            self.alert(title: "Failed to Create Profile", message: message)
    //          case .userNotLoggedIn:
    //            self.alert(title: "Please login first", message: "You muust be logged in to create profiles")
    //          default:
    //            self.alert(title: "Oopsie",
    // message: "Our server made an oopsie woopsie.  Please try again or let us know and we will do our best to fix it ASAP (support@getpear.com)")
    //          }
    //          self.stylize()
    //          self.inputTextField.text = ""
    //          self.inputTextField.isEnabled = true
    //          self.nextButton.isEnabled = true
    //          self.activityIndicator.stopAnimating()
    //        }
    //
    //      }
    //    }
  }
  
}

// MARK: - Life Cycle
extension UserNameInputViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
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
        self.alert(title: "Tell your friend",
                   message: "You must let your friend know of their profile, and they must accept it to continue")
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
