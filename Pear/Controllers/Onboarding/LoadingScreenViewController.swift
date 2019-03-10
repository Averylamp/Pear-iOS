//
//  LoadingScreenViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/3/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
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
    DataStore.shared.checkForExistingUser(pearUserFoundCompletion: {
      self.continueToMainScreen()
    }, userNotFoundCompletion: {
      self.continueToLandingScreen()
    })
  }
  
  func checkForDetachedProfiles() {
    if let user = DataStore.shared.currentPearUser {
      PearProfileAPI.shared.checkDetachedProfiles(phoneNumber: user.phoneNumber) { (result) in
        switch result {
        case .success(let detachedProfiles):
          print(detachedProfiles)
          
        case .failure(let error):
          print("Error checking for Detached Profiles: \(error)")
        }
      }
      
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
    self.checkForDetachedProfiles()
    DispatchQueue.main.async {
      guard let waitlistVC = GetStartedWaitlistViewController.instantiate() else {
        print("Failed to create Landing Screen VC")
        return
      }
      self.navigationController?.setViewControllers([waitlistVC], animated: true)
    }
  }
  
}
