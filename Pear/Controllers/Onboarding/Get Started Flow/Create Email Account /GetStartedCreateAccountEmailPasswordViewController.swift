//
//  GetStartedFriendNameViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAuth

class GetStartedCreateAccountEmailPasswordViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var firstPasswordTextField: UITextField!
    @IBOutlet weak var emailLinkButton: UIButton!

    var gettingStartedData: GettingStartedUserData!

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GettingStartedUserData) -> GetStartedCreateAccountEmailPasswordViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedCreateAccountEmailPasswordViewController.self), bundle: nil)
        guard let emailPasswordVC = storyboard.instantiateInitialViewController() as? GetStartedCreateAccountEmailPasswordViewController else { return nil }
        emailPasswordVC.gettingStartedData = gettingStartedData
        return emailPasswordVC
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
        if StylingConfig.shouldSkipLogin {
//            guard let photoInputVC = GetStartedPhotoInputViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
//                print("Failed to Create Photo Input VC")
//                return
//            }
//            self.navigationController?.pushViewController(photoInputVC, animated: true)
        }

        if let userEmail = self.gettingStartedData.email, let password = self.firstPasswordTextField.text {
            if password.count < 8 {
                self.alert(title: "Password not long enough", message: "Please choose a password with at least 8 characters")
                return
            }
            Auth.auth().createUser(withEmail: userEmail, password: password) { (_, error) in
                if let error = error {
                    self.alert(title: "Sign up error", message: error.localizedDescription)
                    return
                }

                UserDefaults.standard.set(userEmail, forKey: "Email")
//                let credential = EmailAuthProvider.credential(withEmail: userEmail, password: password)
//                guard let user = authResult?.user else { return }

//                guard let photoInputVC = GetStartedPhotoInputViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
//                    print("Failed to create Photo Input VC")
//                    return
//                }
//                self.navigationController?.pushViewController(photoInputVC, animated: true)
            }
        }
    }

    @IBAction func clearFirstPasswordButtonClicked(_ sender: Any) {
        self.firstPasswordTextField.text = ""
    }

}

// MARK: - Life Cycle
extension GetStartedCreateAccountEmailPasswordViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.contentMode = .scaleAspectFit
        self.firstPasswordTextField.becomeFirstResponder()
        self.emailLinkButton.layer.cornerRadius = 20
        self.emailLinkButton.layer.borderWidth = 1
        self.emailLinkButton.layer.borderColor = UIColor.black.cgColor

    }

}

// MARK: - @IBAction
extension GetStartedCreateAccountEmailPasswordViewController {

    @objc func sendEmailLinkSignIn() {

    }

}
