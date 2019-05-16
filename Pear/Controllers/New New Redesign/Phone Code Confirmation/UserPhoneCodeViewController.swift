//
//  UserPhoneCodeViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import NVActivityIndicatorView

class UserPhoneCodeViewController: UIViewController {

  var userCreationData: UserCreationData!
  var verificationID: String!
  var numberLabels: [UILabel] = []
  var circleViews: [UIView] = []
  var isVerifying: Bool = false
  var resendButtonTime: Int = 15
  
  @IBOutlet weak var headerContainerView: UIView!
  @IBOutlet weak var resendButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var verificationView: UIView!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var hiddenInputField: UITextField!
  @IBOutlet weak var resendButton: UIButton!
  @IBOutlet weak var backButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(userCreationData: UserCreationData, verificationID: String) -> UserPhoneCodeViewController? {
    guard let phoneCodeVC = R.storyboard.userPhoneCodeViewController().instantiateInitialViewController() as? UserPhoneCodeViewController else { return nil }
    phoneCodeVC.userCreationData = userCreationData
    phoneCodeVC.verificationID = verificationID
    return phoneCodeVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func resendButtonClicked(_ sender: Any) {
    if resendButtonTime <= 0 {
      Analytics.logEvent("CP_phoneAuth_TAP_resendCode", parameters: nil)
      self.hiddenInputField.text = ""
      self.updateCodeNumberLabels()
      if let phoneNumber = self.userCreationData.phoneNumber {
        let fullPhoneNumber = "+1" + phoneNumber
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
        self.hiddenInputField.isEnabled = false
        self.resendButton.setTitleColor(UIColor.white, for: .normal)
        self.resendButton.isEnabled = false
        let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                                        type: NVActivityIndicatorType.lineScalePulseOut,
                                                        color: UIColor(white: 1.0, alpha: 0.7),
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
          
          self.resendButton.isEnabled = true
          self.hiddenInputField.isEnabled = true
          self.resendButton.setTitleColor(UIColor(white: 0.0, alpha: 0.3), for: .normal)
          self.resendButton.setTitle("Resend in 0:\(String(format: "%02d", self.resendButtonTime))", for: .normal)

          if let error = error {
            HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
            self.alert(title: "Error validating Phone Number", message: error.localizedDescription)
            return
          }
          
          guard let verificationID = verificationID else { return }
          self.verificationID = verificationID
          self.resendButtonTime = 30
          UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
          HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
          self.hiddenInputField.becomeFirstResponder()
        }
      }
    } else {
      HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
    }
  }
  
}

// MARK: - Verification
extension UserPhoneCodeViewController {
  
  func validatePhoneNumberCode() {
    guard !isVerifying else { return }
    guard let fullString = self.hiddenInputField.text else { return }
    guard fullString.count == 6 else { return }
    self.isVerifying = true
    for codeLabel in self.numberLabels {
      codeLabel.textColor = UIColor.black
    }
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: fullString)
    
    Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
      if let error = error as NSError? {
        print(error)
        HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
        DispatchQueue.main.async {
          print(error.localizedDescription)
          
          if error.code == 17025 {
            self.alert(title: "Auth Error", message: "This phone number already associated with another account")
          } else if error.code == 17044 {
            self.alert(title: "Auth Error", message: "Incorrect code")
          } else {
            self.alert(title: "Auth Error", message: "We are currently having issues authenticating your profile")
          }
          self.hiddenInputField.text = ""
          self.updateCodeNumberLabels()
        }
      }
      if let result = result {
        print(result)
        HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
        self.userCreationData.phoneNumberVerified = true
        guard let authUID = Auth.auth().currentUser?.uid else {
          print("Failed to sign in properly")
          return
        }
        DataStore.shared.refreshPearUser { (user) in
          if let user = user {
            print("Continuing to Main Screen")
            DispatchQueue.main.async {
              Analytics.logEvent(AnalyticsEventLogin, parameters: [ AnalyticsParameterMethod: "phone" ])
              DataStore.shared.reloadAllUserData()
              if user.email != nil {
                DispatchQueue.main.async {
                  // TODO(@averylamp): Fix
                  guard let userEmailVC = UserEmailInfoViewController.instantiate() else {
                    print("Failed to create user email VC")
                    return
                  }
                  self.navigationController?.setViewControllers([userEmailVC], animated: true)
                  return
                  
                }
                return
              }
              if let mainVC = LoadingScreenViewController.getMainScreenVC() {
                self.navigationController?.setViewControllers([mainVC], animated: true)
              }
            }
          } else {
            self.userCreationData.firebaseAuthID = authUID
            PearUserAPI.shared.createNewUser(userCreationData: self.userCreationData, completion: { (result) in
              switch result {
              case .success(let pearUser):
                Analytics.logEvent(AnalyticsEventSignUp, parameters: [ AnalyticsParameterMethod: "phone" ])
                if let mondayDate = Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) {
                  let dateFormatter = DateFormatter()
                  dateFormatter.dateFormat = "yy-MM-dd"
                  Analytics.setUserProperty(dateFormatter.string(from: mondayDate), forName: "signup_week")
                }
                DispatchQueue.main.async {
                  DataStore.shared.currentPearUser = pearUser
                  DataStore.shared.reloadAllUserData()
                  DataStore.shared.refreshPearUser(completion: nil)
                  // TODO(@averylamp): Fix
//                  guard let contactPermissionVC = LoadingScreenViewController.getProfileCreationVC() else {
//                    print("Failed to instantiate contact permisssion vc")
//                    return
//                  }
//                  self.navigationController?.setViewControllers([contactPermissionVC], animated: true)
                }
              case .failure(let error):
                print("Failure creating Pear User: \(error)")
                DispatchQueue.main.async {
                  self.hiddenInputField.text = ""
                  self.updateCodeNumberLabels()
                  self.alert(title: "Error creating User",
                             message: "Unfortunately we are unable to create your user at this time, please try again later")
                }
              }
            })
          }
        }
        
      }
      self.isVerifying = false
    }
  }

}

// MARK: - Life Cycle
extension UserPhoneCodeViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setupVerificationView()
    self.addKeyboardNotifications(animated: true)
    self.hiddenInputField.becomeFirstResponder()
    self.hiddenInputField.delegate = self
  }
  
  func stylize() {
    self.view.backgroundColor = UIColor.white
    self.headerContainerView.backgroundColor = nil
//    self.headerContainerView.layer.borderWidth = 1.0
//    self.headerContainerView.layer.borderColor = R.color.backgroundColorDarkPurple()?.cgColor
    if let phoneNumber = self.userCreationData.phoneNumber {
      self.subtitleLabel.text = "Sent to +1 \(String.formatPhoneNumber(phoneNumber: phoneNumber))"
    }
    self.titleLabel.stylizeOnboardingTitleLabel()
    self.subtitleLabel.textColor = R.color.primaryTextColor()
    self.backButton.setImage(R.image.iconLeftArrow(), for: .normal)
    if let font = R.font.openSansExtraBold(size: 16) {
      self.resendButton.titleLabel?.font = font
      
    }
    self.resendButton.backgroundColor = nil
    self.resendButton.setTitleColor(UIColor(white: 0.8, alpha: 1.0), for: .normal)
    self.resendButton.setTitle("Resend in 0:\(String(format: "%02d", self.resendButtonTime))", for: .normal)
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
      self.resendButtonTime -= 1
      if self.resendButtonTime > 0 {
        self.resendButton.setTitle("Resend in 0:\(String(format: "%02d", self.resendButtonTime))", for: .normal)
      } else {
        self.resendButton.setTitle("Resend Code", for: .normal)
      }
    }
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
      circleView.tag = codeItemNumber
      self.circleViews.append(circleView)
      self.verificationView.addSubview(circleView)
      
      let numberLabel = UILabel(frame: CGRect(x: circleView.frame.origin.x, y: circleView.frame.origin.y, width: circleView.frame.width, height: circleView.frame.height))
      if let font = R.font.openSansExtraBold(size: 24) {
        numberLabel.font = font
      }
      numberLabel.textColor = R.color.primaryTextColor()
      numberLabel.tag = codeItemNumber
      numberLabel.textAlignment = .center
      self.numberLabels.append(numberLabel)
      self.verificationView.addSubview(numberLabel)
    }
    self.updateCodeNumberLabels()
  }
}

// MARK: - UITextFieldDelegate
extension UserPhoneCodeViewController: UITextFieldDelegate {
  
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
          self.circleViews[labelNumber].backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        } else if labelNumber == text.count {
          self.numberLabels[labelNumber].text = ""
          self.circleViews[labelNumber].backgroundColor = R.color.primaryBrandColor()
        } else {
          self.numberLabels[labelNumber].text = ""
          self.circleViews[labelNumber].backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        }
        self.numberLabels[labelNumber].textColor = R.color.primaryTextColor()
      }
    }
  }
}

// MARK: - Keybaord Size Notifications
extension UserPhoneCodeViewController: KeyboardEventsBottomProtocol {
  var bottomKeyboardConstraint: NSLayoutConstraint? {
    return self.resendButtonBottomConstraint
  }
  
  var bottomKeyboardPadding: CGFloat {
    return 20.0
  }
  
}
