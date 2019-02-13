//
//  GetStartedCreateAccountViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import FacebookLogin
import Firebase

class GetStartedCreateAccountViewController: UIViewController {
    
    var endorsement: Endorsement!
    var authAPI: AuthAPI! =  FakeAuthAPI()
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(endorsement: Endorsement) -> GetStartedCreateAccountViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedCreateAccountViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedCreateAccountViewController
        vc.endorsement = endorsement
        return vc
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func facebookButtonClicked(_ sender: Any) {
        
        showLoadingIndicator()
        
        let loginManager = LoginManager()
        
        // 1. Auth via Facebook.
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { result in
            switch result {
            case .success(_, _, let accessToken):
                
                // 2. Auth via Firebase.
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                Auth.auth().signInAndRetrieveData(with: credential) { authData, error in
                    if let error = error {
                        self.alert(title: "Auth Error", message: error.localizedDescription)
                        return
                    }
                    
//                    guard let user = authData?.user else{ return }
                    let phoneNumberVerificationVC = GetStartedValidatePhoneNumberViewController.instantiate(endorsement: self.endorsement)
                    self.navigationController?.pushViewController(phoneNumberVerificationVC, animated: true)

                }
            case .cancelled:
                break
            case .failed(let error):
                break
            }
        }
    }
    
    @IBAction func emailButtonClicked(_ sender: Any) {
        let emailVC = GetStartedCreateAccountEmailViewController.instantiate(endorsement: self.endorsement)
        self.navigationController?.pushViewController(emailVC, animated: true)
    }
    
}


// MARK: - Life Cycle
extension GetStartedCreateAccountViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
