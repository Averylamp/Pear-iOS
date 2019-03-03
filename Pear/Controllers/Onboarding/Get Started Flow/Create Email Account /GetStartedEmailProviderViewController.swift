//
//  GetStartedYourNameViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import FirebaseAuth

class GetStartedEmailProviderViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!

    var gettingStartedUserData: GettingStartedUserData!

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedUserData: GettingStartedUserData) -> GetStartedEmailProviderViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedEmailProviderViewController.self), bundle: nil)
        guard let emailProviderVC = storyboard.instantiateInitialViewController() as? GetStartedEmailProviderViewController else { return nil }
        emailProviderVC.gettingStartedUserData = gettingStartedUserData
        return emailProviderVC
    }

    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
        if let email = self.inputTextField.text {
            // After asking the user for their email.
            Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
                // This returns the same array as fetchProviders(forEmail:completion:) but for email
                // provider identified by 'password' string, signInMethods would contain 2
                // different strings:
                // 'emailLink' if the user previously signed in with an email/link
                // 'password' if the user has a password.
                // A user could have both.

                self.gettingStartedUserData.email = email

                if error != nil {
                    // Handle error case.
                    self.alert(title: "Email error", message: "Error signing up by email")
                    return
                }

                guard let signInMethods = signInMethods else {
                    if self.gettingStartedUserData.facebookId != nil, let nextInputVC = self.gettingStartedUserData.getNextInputViewController() {
                        self.navigationController?.pushViewController(nextInputVC, animated: true)
                        return
                    }
                    return
                }

                if self.gettingStartedUserData.facebookId != nil, let nextInputVC = self.gettingStartedUserData.getNextInputViewController() {
                    self.navigationController?.pushViewController(nextInputVC, animated: true)
                    return
                }

                var emailPasswordUsed: Bool = false
                var emailLinkUsed: Bool = false
                var facebookUsed: Bool = false
                if signInMethods.contains(EmailPasswordAuthSignInMethod) {
                    // User can sign in with email/password.
                    emailPasswordUsed = true
                    print("Email Password combo")
                }
                if signInMethods.contains(EmailLinkAuthSignInMethod) {
                    print("Email Password combo")
                    emailLinkUsed = true
                    // User can sign in with email/link.
                }
                if signInMethods.contains(FacebookAuthSignInMethod) {
                    facebookUsed = true
                    print("User previously signed up with facebook")
                    // Facebook signup detected
                }

                if !emailPasswordUsed && !emailLinkUsed && !facebookUsed {

                } else {

                }

            }

//            let phoneVerificationVC = GetStartedValidatePhoneNumberViewController.instantiate(gettingStartedData: self.gettingStartedData)
//            self.navigationController?.pushViewController(phoneVerificationVC, animated: true)
        } else {
            self.alert(title: "Email Missing", message: "Please fill out your email")
        }
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func clearButtonClicked(_ sender: Any) {
        self.inputTextField.text = ""
    }
}

// MARK: - Life Cycle
extension GetStartedEmailProviderViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputTextField.becomeFirstResponder()
        self.stylize()
        self.addKeyboardSizeNotifications()
    }

    func stylize() {
        self.titleLabel.stylizeTitleLabel()

        self.nextButton.stylizeDark()
    }

}

// MARK: - Keybaord Size Notifications
extension GetStartedEmailProviderViewController {

    func addKeyboardSizeNotifications() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(GetStartedEmailProviderViewController.keyboardWillChange(notification:)),
                         name: UIWindow.keyboardWillChangeFrameNotification,
                         object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(GetStartedEmailProviderViewController.keyboardWillHide(notification:)),
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
            self.nextButtonBottomConstraint.constant = 0
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
