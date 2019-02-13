//
//  GetStartedFriendNameViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import FirebaseAuth

class GetStartedCreateAccountEmailPasswordViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var firstPasswordTextField: UITextField!
    @IBOutlet weak var emailLinkButton: UIButton!
    
    var gettingStartedData: GetttingStartedData!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GetttingStartedData) -> GetStartedCreateAccountEmailPasswordViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedCreateAccountEmailPasswordViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedCreateAccountEmailPasswordViewController
        vc.gettingStartedData = gettingStartedData
        return vc
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        if Config.shouldSkipLogin {
            let photoInputVC = GetStartedPhotoInputViewController.instantiate(gettingStartedData: self.gettingStartedData)
            self.navigationController?.pushViewController(photoInputVC, animated: true)
        }
        
        
        if let userEmail = self.gettingStartedData.userEmail, let password = self.firstPasswordTextField.text {
            if password.count < 8 {
                self.alert(title: "Password not long enough", message: "Please choose a password with at least 8 characters")
                return
            }
            Auth.auth().createUser(withEmail: userEmail, password: password) { (authResult, error) in
                if let error = error{
                    self.alert(title: "Sign up error", message: error.localizedDescription)
                    return
                }
                
                UserDefaults.standard.set(userEmail, forKey: "Email")
//                let credential = EmailAuthProvider.credential(withEmail: userEmail, password: password)
//                guard let user = authResult?.user else { return }
                
                let photoInputVC = GetStartedPhotoInputViewController.instantiate(gettingStartedData: self.gettingStartedData)
                self.navigationController?.pushViewController(photoInputVC, animated: true)
            }
        }
    }
    
    @IBAction func clearFirstPasswordButtonClicked(_ sender: Any) {
        self.firstPasswordTextField.text = ""
    }
    
}


// MARK: - Life Cycle
extension GetStartedCreateAccountEmailPasswordViewController{
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
extension GetStartedCreateAccountEmailPasswordViewController{
    
    @objc func sendEmailLinkSignIn(){
        
    }
    
}
