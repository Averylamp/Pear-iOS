//
//  LandingScreenViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SafariServices
import NVActivityIndicatorView
import FirebaseAuth
import FirebaseAnalytics

class LandingScreenViewController: UIViewController {
  
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var termsButton: UIButton!
  @IBOutlet weak var phoneNumberContainerView: UIView!
  @IBOutlet weak var inputTextField: UITextField!
  
  var isValidatingPhoneNumber: Bool = false
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> LandingScreenViewController? {
    let landingScreenVC = R.storyboard.landingScreenViewController().instantiateInitialViewController() as? LandingScreenViewController
    return landingScreenVC
  }
  
  @IBAction func termsButtonClicked(_ sender: Any) {
    let actionSheet = UIAlertController(title: "Terms of Service",
                                        message: "What would you like to see?",
                                        preferredStyle: .actionSheet)
    let eulaAction = UIAlertAction(title: "End User License Agreement", style: .default) { (_) in
      self.present(SFSafariViewController(url: NetworkingConfig.eulaURL), animated: true, completion: nil)
    }
    let privacyPolicyAction = UIAlertAction(title: "Privacy Policy", style: .default) { (_) in
      self.present(SFSafariViewController(url: NetworkingConfig.eulaURL), animated: true, completion: nil)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    actionSheet.addAction(eulaAction)
    actionSheet.addAction(privacyPolicyAction)
    actionSheet.addAction(cancelAction)
    self.present(actionSheet, animated: true, completion: nil)
  }
  
  func validatePhoneNumber() {
    guard self.isValidatingPhoneNumber == false else {
      print("Is already validating")
      return
    }
    self.isValidatingPhoneNumber = true
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    
    if let phoneNumber = inputTextField.text?.filter("0123456789".contains), phoneNumber.count == 10 {
      let fullPhoneNumber = "+1" + phoneNumber
      print("Verifying phone number: \(fullPhoneNumber)")
      self.inputTextField.textColor = UIColor.lightGray
      self.inputTextField.isEnabled = false
      let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                                      type: NVActivityIndicatorType.lineScalePulseOut,
                                                      color: UIColor(white: 1.0, alpha: 0.7),
                                                      padding: 0)
      self.view.addSubview(activityIndicator)
      activityIndicator.center = CGPoint(x: self.view.center.x,
                                         y: self.logoImageView.frame.origin.y - 40)
      activityIndicator.startAnimating()
      
      PhoneAuthProvider.provider().verifyPhoneNumber(fullPhoneNumber, uiDelegate: nil) { (verificationID, error) in
        
        UIView.animate(withDuration: 0.5, animations: {
          activityIndicator.alpha = 0.0
        }, completion: { (_) in
          activityIndicator.stopAnimating()
          activityIndicator.removeFromSuperview()
        })
        
        self.inputTextField.textColor = StylingConfig.textFontColor
        self.inputTextField.isEnabled = true
        if let error = error {
          self.alert(title: "Error validating Phone Number", message: error.localizedDescription)
          print(error)
          HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
          self.isValidatingPhoneNumber = false
          return
        }
        self.isValidatingPhoneNumber = false
        guard let verificationID = verificationID else { return }
        print("Phone number validated, \(fullPhoneNumber), \(phoneNumber)")
        // Sign in using the verificationID and the code sent to the user
        // ...
        UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        
        HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
        let userCreationData = UserCreationData()
        userCreationData.phoneNumber = phoneNumber
        guard let phoneNumberVC = UserPhoneCodeViewController.instantiate(userCreationData: userCreationData,
                                                                          verificationID: verificationID) else {
          print("Failed to create Phone Number Code VC")
          return
        }
        Analytics.logEvent("finished_phone_enter", parameters: nil)
        self.navigationController?.pushViewController(phoneNumberVC, animated: true)
      }
    } else {
      self.alert(title: "Phone number not detected", message: "Please input your 10 digit phone number")
      self.isValidatingPhoneNumber = false
    }
    
  }
  
}

// MARK: - Life Cycle
extension LandingScreenViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.inputTextField.delegate = self
    self.addDismissKeyboardOnViewClick()
  }
  
  func stylize() {
    self.view.backgroundColor = R.color.backgroundColorGreen()
    
    guard let textFont = R.font.openSansLight(size: 11),
      let boldFont = R.font.openSansSemiBold(size: 11) else {
        print("Failed to load in fonts")
        return
    }
    let subtleAttributes = [NSAttributedString.Key.font: textFont,
                            NSAttributedString.Key.foregroundColor: UIColor(white: 0.95, alpha: 1.0)]
    let boldAttributes = [NSAttributedString.Key.font: boldFont,
                          NSAttributedString.Key.foregroundColor: UIColor(white: 0.95, alpha: 1.0)]
    let termsString = NSMutableAttributedString(string: "By continuing you agree to our ",
                                                attributes: subtleAttributes)
    let eulaString = NSMutableAttributedString(string: "EULA",
                                               attributes: boldAttributes)
    let andString = NSMutableAttributedString(string: " and ",
                                              attributes: subtleAttributes)
    let privacyPolicyString = NSMutableAttributedString(string: "privacy policy",
                                                        attributes: boldAttributes)
    termsString.append(eulaString)
    termsString.append(andString)
    termsString.append(privacyPolicyString)
    self.termsButton.setAttributedTitle(termsString, for: .normal)
    
    self.phoneNumberContainerView.layer.cornerRadius = 8
    
  }
  
}

// MARK: - UITextFieldDelegate
extension LandingScreenViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    var fullString = textField.text ?? ""
    fullString.append(string.filter("0123456789".contains))
    if range.length == 1 {
      textField.text = String.formatPhoneNumber(phoneNumber: fullString, shouldRemoveLastDigit: true)
    } else if string == " "{
      return true
    } else if string.count != 0 {
      if fullString.filter("0123456789".contains).count == 11 && "1" == fullString.filter("0123456789".contains).substring(toIndex: 1) {
        textField.text = String.formatPhoneNumber(phoneNumber: fullString.filter("0123456789".contains).substring(fromIndex: 1))
        if let phoneNumber = inputTextField.text?.filter("0123456789".contains), phoneNumber.count == 10 {
          self.validatePhoneNumber()
        }
      } else {
        textField.text = String.formatPhoneNumber(phoneNumber: fullString)
      }
    }
    if let phoneText = self.inputTextField.text, phoneText.filter("0123456789".contains).count == 10 {
      print("Full Phone Number")
      self.validatePhoneNumber()
    }
    return false
  }
  
}

// MARK: - Dismiss First Responder on Click
extension LandingScreenViewController {
  
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LandingScreenViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.view.endEditing(true)
  }
  
}
