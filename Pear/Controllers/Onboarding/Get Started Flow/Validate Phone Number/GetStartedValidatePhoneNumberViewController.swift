//
//  GetStartedValidatePhoneNumberViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/10/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import FirebaseAuth
import NVActivityIndicatorView

class GetStartedValidatePhoneNumberViewController: UIViewController {

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!

    @IBOutlet weak var titleLabel: UILabel!

    var gettingStartedUserData: GettingStartedUserData!

    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedUserData: GettingStartedUserData) -> GetStartedValidatePhoneNumberViewController? {

        let storyboard = UIStoryboard(name: String(describing: GetStartedValidatePhoneNumberViewController.self), bundle: nil)
        guard let validatePhoneNumberVC = storyboard.instantiateInitialViewController() as? GetStartedValidatePhoneNumberViewController else { return nil }
        validatePhoneNumberVC.gettingStartedUserData = gettingStartedUserData
        return validatePhoneNumberVC
    }

    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)

        if let phoneNumber = inputTextField.text?.filter("0123456789".contains), phoneNumber.count == 10 {
            let fullPhoneNumber = "+1" + phoneNumber
            print("Verifying phone number")
            self.inputTextField.textColor = UIColor.lightGray
            self.inputTextField.isEnabled = false
            self.nextButton.backgroundColor = UIColor.white
            self.nextButton.setTitleColor(Config.nextButtonColor, for: .normal)
            self.nextButton.isEnabled = false
            let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                                            type: NVActivityIndicatorType.ballScaleRippleMultiple,
                                                            color: Config.textFontColor,
                                                            padding: 0)
            self.view.addSubview(activityIndicator)
            activityIndicator.center = CGPoint(x: self.view.center.x, y: self.inputTextField.frame.origin.y + self.inputTextField.frame.height + 40)
            activityIndicator.startAnimating()
            PhoneAuthProvider.provider().verifyPhoneNumber(fullPhoneNumber, uiDelegate: nil) { (verificationID, error) in
                activityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.5, animations: {
                    activityIndicator.alpha = 0.0
                }, completion: { (_) in
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                })
                self.inputTextField.textColor = Config.textFontColor
                self.inputTextField.isEnabled = true
                self.nextButton.backgroundColor = Config.nextButtonColor
                self.nextButton.setTitleColor(UIColor.white, for: .normal)
                self.nextButton.isEnabled = true
                if let error = error {
                    self.alert(title: "Error validating Phone Number", message: error.localizedDescription)
                    HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
                    return
                }

                guard let verificationID = verificationID else { return }
                self.gettingStartedUserData.phoneNumber = phoneNumber
                print("Phone number validated, \(fullPhoneNumber), \(phoneNumber)")
                // Sign in using the verificationID and the code sent to the user
                // ...
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")

                HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
                guard let phoneNumberCodeVC = GetStartedValidatePhoneNumberCodeViewController
                    .instantiate(gettingStartedUserData: self.gettingStartedUserData, verificationID: verificationID) else {
                    print("Failed to create Phone Number Code VC")
                    return
                }
                self.navigationController?.pushViewController(phoneNumberCodeVC, animated: true)
            }
        } else {
            self.alert(title: "Phone number not detected", message: "Please input your 10 digit phone number")

        }

    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: - Life Cycle
extension GetStartedValidatePhoneNumberViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputTextField.becomeFirstResponder()
        self.inputTextField.delegate = self
        self.styleViews()
        self.addKeyboardSizeNotifications()

    }

    func styleViews() {
        self.titleLabel.font = UIFont(name: Config.displayFontRegular, size: 28)
        self.titleLabel.textColor = Config.textFontColor
        if let firstName = self.gettingStartedUserData.firstName {
            self.titleLabel.text = "Hi, \(firstName)!  To verify you, we need your phone #"
        } else {
            self.titleLabel.text = "Hi!  To verify you, we need your phone #"
        }

        self.inputTextField.textColor = Config.textFontColor

        self.nextButton.backgroundColor = Config.nextButtonColor
        self.nextButton.layer.cornerRadius = self.nextButton.frame.height / 2.0
        self.nextButton.layer.shadowRadius = 1
        self.nextButton.layer.shadowColor = UIColor(white: 0.0, alpha: 0.15).cgColor
        self.nextButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.nextButton.layer.shadowOpacity = 1.0
        self.nextButton.setTitleColor(UIColor.white, for: .normal)
        self.nextButton.titleLabel?.font = UIFont(name: Config.textFontSemiBold, size: 17)

    }

}

// MARK: - UITextFieldDelegate
extension GetStartedValidatePhoneNumberViewController: UITextFieldDelegate {

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
                    self.nextButtonClicked(self.nextButton)
                }
            } else {
                textField.text = String.formatPhoneNumber(phoneNumber: fullString)
            }
        }
        return false
    }

}

// MARK: - Keybaord Size Notifications
extension GetStartedValidatePhoneNumberViewController {

    func addKeyboardSizeNotifications() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(GetStartedValidatePhoneNumberViewController.keyboardWillChange(notification:)),
                         name: UIWindow.keyboardWillChangeFrameNotification,
                         object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(GetStartedValidatePhoneNumberViewController.keyboardWillHide(notification:)),
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
