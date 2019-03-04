//
//  LoadingScreenViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/3/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import Firebase

class LoadingScreenViewController: UIViewController {

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> LoadingScreenViewController? {
        let storyboard = UIStoryboard(name: String(describing: LoadingScreenViewController.self), bundle: nil)
        guard let loadingScreenVC = storyboard.instantiateInitialViewController() as? LoadingScreenViewController else { return nil }

        return loadingScreenVC
    }

}

// MARK: - Life Cycle
extension LoadingScreenViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkForExistingUser()
    }

    func checkForExistingUser() {

        if let currentUser = Auth.auth().currentUser {
            let uid = currentUser.uid
            currentUser.getIDToken { (token, error) in
                if let error = error {
                    print("Error getting token: \(error)")
                    self.continueToLandingScreen()
                    return
                }
                if let token = token {
                    PearUserAPI.shared.getUser(uid: uid,
                                               token: token,
                                               completion: { (result) in
                            switch result {
                            case .success(let pearUser):
                                print("Got Existing Pear User \(pearUser)")
                                self.continueToMainScreen()
                            case .failure(let error):
                                print("Error getting Pear User: \(error)")
                                self.continueToLandingScreen()
                            }
                    })

                } else {
                    print("No token found")
                    self.continueToLandingScreen()
                }
            }
        } else {
            self.continueToLandingScreen()
        }
    }

    func continueToLandingScreen() {
        print("Continuing to Landing Screen")
        DispatchQueue.main.async {
            guard let loadingScreenVC = LandingScreenViewController.instantiate() else {
                print("Failed to create Landing Screen VC")
                return
            }
            self.navigationController?.setViewControllers([loadingScreenVC], animated: true)
        }
    }

    func continueToMainScreen() {
        print("Continuing to Main Screen")
        DispatchQueue.main.async {
            guard let waitlistVC = GetStartedWaitlistViewController.instantiate() else {
                print("Failed to create Landing Screen VC")
                return
            }
            self.navigationController?.setViewControllers([waitlistVC], animated: true)
        }
    }

}
