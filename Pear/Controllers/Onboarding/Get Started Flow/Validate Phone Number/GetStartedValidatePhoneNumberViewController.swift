//
//  GetStartedValidatePhoneNumberViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/10/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import FirebaseAuth

class GetStartedValidatePhoneNumberViewController: UIViewController {
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var endorsement: Endorsement!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(endorsement: Endorsement) -> GetStartedValidatePhoneNumberViewController {
        
        let storyboard = UIStoryboard(name: String(describing: GetStartedValidatePhoneNumberViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedValidatePhoneNumberViewController
        vc.endorsement = endorsement
        return vc
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        self.showLoadingIndicator()
        if let phoneNumber = inputTextField.text, phoneNumber.count >= 10 {
            print(phoneNumber)
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    self.alert(title: "Error validating Phone Number", message: error.localizedDescription)
                    return
                }
                
                guard let verificationID = verificationID else { return }
                self.endorsement.userPhoneNumber = phoneNumber
                print("Phone number validated")
                // Sign in using the verificationID and the code sent to the user
                // ...
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                
                let phoneNumberCodeVC = GetStartedValidatePhoneNumberCodeViewController.instantiate(endorsement: self.endorsement, verificationID: verificationID)
                self.navigationController?.pushViewController(phoneNumberCodeVC, animated: true)
            }
        }
        
//        // 3. Get Firebase Verify ID token.
//        authData!.user.getIDTokenForcingRefresh(true) { token, error in
//            if let error = error {
//                self.alert(title: "Auth Error", message: error.localizedDescription)
//                return
//            }
//
//            guard let token = token else {
//                self.alert(title: "Auth Error", message: "Unknown error occurred")
//                return
//            }
//            // 4. Trade ID token for our own auth token.
//            self.authAPI.login(with: .firebase(token: token)) { result in
//                self.hideLoadingIndicator()
//                switch result {
//                case .success:
//                    guard let user = authData?.user else { return }
//
//                    break
//                case .failure(let error):
//                    self.alert(title: "Auth Error", message: error.localizedDescription)
//                }
//            }
//        }

    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}


// MARK: - Life Cycle
extension GetStartedValidatePhoneNumberViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputTextField.becomeFirstResponder()
    }
    
}

// MARK: - UITextFieldDelegate
extension GetStartedValidatePhoneNumberViewController: UITextFieldDelegate{
    
    
    
}
