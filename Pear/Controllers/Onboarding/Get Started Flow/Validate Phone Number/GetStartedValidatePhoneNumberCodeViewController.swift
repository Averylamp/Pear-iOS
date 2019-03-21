//
//  GetStartedValidatePhoneNumberCodeViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import NVActivityIndicatorView

class GetStartedValidatePhoneNumberCodeViewController: UIViewController {
  
  @IBOutlet weak var hiddenInputField: UITextField!
  @IBOutlet weak var verificationView: UIView!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var resendCodeButton: UIButton!
  @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
  
  var numberLabels: [UILabel] = []
  var circleViews: [UIView] = []
  var gettingStartedUserData: UserCreationData!
  var verificationID: String!
  var isVerifying: Bool = false
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedUserData: UserCreationData, verificationID: String) -> GetStartedValidatePhoneNumberCodeViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedValidatePhoneNumberCodeViewController.self), bundle: nil)
    guard let phoneNumberCodeVC = storyboard.instantiateInitialViewController() as? GetStartedValidatePhoneNumberCodeViewController else { return nil }
    phoneNumberCodeVC.gettingStartedUserData = gettingStartedUserData
    phoneNumberCodeVC.verificationID = verificationID
    return phoneNumberCodeVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func resendCodeButtonClicked(_ sender: Any) {
    self.hiddenInputField.text = ""
    self.updateCodeNumberLabels()
    if let phoneNumber = self.gettingStartedUserData.phoneNumber {
      let fullPhoneNumber = "+1" + phoneNumber
      HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
      self.hiddenInputField.isEnabled = false
      self.resendCodeButton.setTitleColor(UIColor.darkGray, for: .normal)
      self.resendCodeButton.backgroundColor = UIColor.lightGray
      self.resendCodeButton.isEnabled = false
      let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                                      type: NVActivityIndicatorType.ballScaleRippleMultiple,
                                                      color: StylingConfig.textFontColor,
                                                      padding: 0)
      self.view.addSubview(activityIndicator)
      activityIndicator.center = CGPoint(x: self.view.center.x, y: self.verificationView.frame.origin.y + self.verificationView.frame.height + 40)
      activityIndicator.startAnimating()
      PhoneAuthProvider.provider().verifyPhoneNumber(fullPhoneNumber, uiDelegate: nil) { (verificationID, error) in
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.5, animations: {
          activityIndicator.alpha = 0.0
        }, completion: { (_) in
          activityIndicator.stopAnimating()
          activityIndicator.removeFromSuperview()
        })
        
        self.resendCodeButton.isEnabled = true
        self.hiddenInputField.isEnabled = true
        self.resendCodeButton.setTitleColor(StylingConfig.textFontColor, for: .normal)
        self.resendCodeButton.backgroundColor = UIColor.white
        
        if let error = error {
          HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
          self.alert(title: "Error validating Phone Number", message: error.localizedDescription)
          return
        }
        
        guard let verificationID = verificationID else { return }
        
        // Sign in using the verificationID and the code sent to the user
        // ...
        UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        
        HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
        self.hiddenInputField.becomeFirstResponder()
      }
    }
  }
}

// MARK: - Life Cycle
extension GetStartedValidatePhoneNumberCodeViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.hiddenInputField.becomeFirstResponder()
    self.hiddenInputField.delegate = self
    self.stylize()
    self.setupVerificationView()
    self.updateCodeNumberLabels()
    self.addKeyboardSizeNotifications()
  }
  
  func stylize() {
    if let phoneNumber = self.gettingStartedUserData.phoneNumber {
      self.subtitleLabel.text = "Sent to +1 \(String.formatPhoneNumber(phoneNumber: phoneNumber))"
    }
    
    self.resendCodeButton.stylizeLight()
  }
  
  func setupVerificationView() {
    self.view.layoutIfNeeded()
    let sideInsets: CGFloat = 30
    let numberSpacing: CGFloat = 4
    let fullUsableSpace: CGFloat = self.verificationView.frame.width - (2 * sideInsets)
    let lineWidth: CGFloat = (fullUsableSpace - (5 * numberSpacing) ) / 6.0
    for codeItemNumber in 0..<6 {
      let circleView = UIView(frame: CGRect(x: sideInsets + CGFloat(codeItemNumber) * ( lineWidth + numberSpacing), y: 0, width: lineWidth, height: lineWidth))
      circleView.layer.cornerRadius = lineWidth / 2.0
      circleView.layer.borderWidth = 1
      circleView.layer.borderColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00).cgColor
      circleView.tag = codeItemNumber
      self.circleViews.append(circleView)
      self.verificationView.addSubview(circleView)
      
      let numberLabel = UILabel(frame: CGRect(x: circleView.frame.origin.x, y: circleView.frame.origin.y, width: circleView.frame.width, height: circleView.frame.height))
      numberLabel.font = UIFont(name: StylingConfig.displayFontMedium, size: 26)
      numberLabel.textColor = StylingConfig.textFontColor
      numberLabel.tag = codeItemNumber
      numberLabel.textAlignment = .center
      self.numberLabels.append(numberLabel)
      self.verificationView.addSubview(numberLabel)
    }
  }
  
  func validatePhoneNumberCode() {
    guard !isVerifying else { return }
    guard let fullString = self.hiddenInputField.text else { return }
    guard fullString.count == 6 else { return }
    self.isVerifying = true
    for codeLabel in self.numberLabels {
      codeLabel.textColor = UIColor.lightGray
    }
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: fullString)
    if let user = Auth.auth().currentUser {
      user.linkAndRetrieveData(with: credential) { (_, error) in
        if let error = error {
          print(error)
          HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
          guard let verificationCompleteVC = GetStartedPhoneVerificationCompleteViewController.instantiate() else {
            print("Failed to create Verification Complete VC")
            return
          }
          self.navigationController?.pushViewController(verificationCompleteVC, animated: true)
          //                    self.alert(title: "Auth Error", message: error.localizedDescription)
          //                    self.hiddenInputField.text = ""
          //                    self.updateCodeNumberLabels()
        } else {
          HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
          self.gettingStartedUserData.phoneNumberVerified = true
          user.getIDToken(completion: { (authToken, error) in
            if let error = error {
              print("Error getting token: \(error)")
            }
            if let authToken = authToken {
              self.gettingStartedUserData.firebaseToken = authToken
              print(self.gettingStartedUserData)
              PearUserAPI.shared.createNewUser(with: self.gettingStartedUserData, completion: { (result) in
                print("Create User API Called")
                switch result {
                case .success(let pearUser):
                  print(pearUser)
                  DataStore.shared.currentPearUser = pearUser
                  DispatchQueue.main.async {
                    guard let verificationCompleteVC = GetStartedPhoneVerificationCompleteViewController.instantiate() else {
                      print("Failed to create Verification Complete VC")
                      return
                    }
                    self.navigationController?.pushViewController(verificationCompleteVC, animated: true)
                  }
                case .failure(let error):
                  print(error)
                  DispatchQueue.main.async {
                    //                                        self.alert(title: "Error creating User", message: error.localizedDescription)
                    guard let verificationCompleteVC = GetStartedPhoneVerificationCompleteViewController.instantiate() else {
                      print("Failed to create Verification Complete VC")
                      return
                    }
                    self.navigationController?.pushViewController(verificationCompleteVC, animated: true)
                    
                  }
                }
              })
              
            }
          })
          
        }
      }
    }
    
  }
  
}

// MARK: - UITextFieldDelegate
extension GetStartedValidatePhoneNumberCodeViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    var fullString = textField.text ?? ""
    fullString.append(string.filter("0123456789".contains))
    if range.length == 1 && fullString.count > 0 {
      fullString = fullString.substring(toIndex: fullString.count - 1)
    }
    
    // Prevent from overflowing
    fullString = fullString.substring(toIndex: 6)
    
    textField.text = fullString
    self.updateCodeNumberLabels()
    
    if fullString.count == 6 {
      self.validatePhoneNumberCode()
    }
    return false
  }
  
  func updateCodeNumberLabels() {
    if let text = self.hiddenInputField.text {
      for labelNumber in 0 ..< self.numberLabels.count {
        if labelNumber < text.count {
          self.numberLabels[labelNumber].text = text[labelNumber..<labelNumber+1]
          self.numberLabels[labelNumber].textColor = StylingConfig.textFontColor
          self.circleViews[labelNumber].layer.borderColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00).cgColor
        } else if labelNumber == text.count {
          self.numberLabels[labelNumber].text = ""
          self.numberLabels[labelNumber].textColor = StylingConfig.textFontColor
          self.circleViews[labelNumber].layer.borderColor = UIColor(red: 0.26, green: 0.29, blue: 0.33, alpha: 1.00).cgColor
        } else {
          self.numberLabels[labelNumber].text = ""
          self.numberLabels[labelNumber].textColor = StylingConfig.textFontColor
          self.circleViews[labelNumber].layer.borderColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00).cgColor
        }
      }
    }
  }
}

// MARK: - Keybaord Size Notifications
extension GetStartedValidatePhoneNumberCodeViewController {
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(GetStartedValidatePhoneNumberCodeViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(GetStartedValidatePhoneNumberCodeViewController.keyboardWillHide(notification:)),
                   name: UIWindow.keyboardWillHideNotification,
                   object: nil)
  }
  
  @objc func keyboardWillChange(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
      let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let targetFrame = targetFrameNSValue.cgRectValue
      let keyboardBottomPadding: CGFloat = 20
      self.nextButtonBottomConstraint.constant = targetFrame.size.height - self.view.safeAreaInsets.bottom + keyboardBottomPadding
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  @objc func keyboardWillHide(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      let keyboardBottomPadding: CGFloat = 20
      self.nextButtonBottomConstraint.constant = keyboardBottomPadding
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
}
