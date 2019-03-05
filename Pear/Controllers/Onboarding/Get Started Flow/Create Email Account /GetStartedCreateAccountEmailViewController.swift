//
//  GetStartedFriendNameViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import FirebaseAuth

class GetStartedCreateAccountEmailViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!

    var gettingStartedData: GettingStartedUserProfileData!

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GettingStartedUserProfileData) -> GetStartedCreateAccountEmailViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedCreateAccountEmailViewController.self), bundle: nil)
        guard let createAccountEmailVC = storyboard.instantiateInitialViewController() as? GetStartedCreateAccountEmailViewController else { return nil }
        createAccountEmailVC.gettingStartedData = gettingStartedData
        return createAccountEmailVC
    }

    func saveUserEmail() {
//        if let userEmail = inputTextField.text {
//            gettingStartedData.userEmail = userEmail
//        }
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.saveUserEmail()
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)

        self.saveUserEmail()
//        guard let emailPasswordVC = GetStartedCreateAccountEmailPasswordViewController.instantiate(gettingStartedData: gettingStartedData) else {
//            print("Failed to create Email Password VC")
//            return
//        }
//        self.navigationController?.pushViewController(emailPasswordVC, animated: true)
    }

    @IBAction func clearButtonClicked(_ sender: Any) {
        self.inputTextField.text = ""
    }
}

// MARK: - Life Cycle
extension GetStartedCreateAccountEmailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.contentMode = .scaleAspectFit
        self.inputTextField.becomeFirstResponder()
    }

}
