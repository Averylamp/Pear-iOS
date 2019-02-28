//
//  LoginVC.swift
//  SubtleAsianMatches
//
//  Created by Kelvin Lau on 2018-12-26.
//  Copyright © 2018 sam. All rights reserved.
//

import UIKit
import FacebookLogin
import Firebase

final class LoginVC: UIViewController {

    private var authAPI: AuthAPI!

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(authAPI: AuthAPI) -> LoginVC? {
        let storyboard = UIStoryboard(name: String(describing: LoginVC.self), bundle: nil)
        guard let loginVC = storyboard.instantiateInitialViewController() as? LoginVC else { return nil }
        loginVC.authAPI = authAPI
        return loginVC
    }
}

// MARK: - Life Cycle
extension LoginVC {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - @IBActions
private extension LoginVC {

    @IBAction func fbLoginTapped() {
        showLoadingIndicator()

        let loginManager = LoginManager()
        // 1. Auth via Facebook.
        loginManager.logIn(readPermissions: [.publicProfile], viewController: self) { result in
            switch result {
            case .success(_, _, let accessToken):

                // 2. Auth via Firebase.
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                Auth.auth().signInAndRetrieveData(with: credential) { result, error in
                    if let error = error {
                        self.alert(title: "Auth Error", message: error.localizedDescription)
                        return
                    }

                    // 3. Get Firebase Verify ID token.
                    result!.user.getIDTokenForcingRefresh(true) { token, error in
                        if let error = error {
                            self.alert(title: "Auth Error", message: error.localizedDescription)
                            return
                        }

                        guard let token = token else {
                            self.alert(title: "Auth Error", message: "Unknown error occurred")
                            return
                        }
                        // 4. Trade ID token for our own auth token.
                        self.authAPI.login(with: .firebase(token: token)) { result in
                            self.hideLoadingIndicator()
                            switch result {
                            case .success:
                                break
                            case .failure(let error):
                                self.alert(title: "Auth Error", message: error.localizedDescription)
                            }
                        }
                    }
                }
            case .cancelled:
                break
            case .failed:
                break
            }
        }
    }
}
