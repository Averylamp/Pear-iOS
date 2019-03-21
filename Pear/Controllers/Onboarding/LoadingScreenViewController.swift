//
//  LoadingScreenViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/3/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebasePerformance

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
    self.testImageUpload()
    DataStore.shared.checkForExistingUser(pearUserFoundCompletion: {
      self.continueToMainScreen()
    }, userNotFoundCompletion: {
      self.continueToLandingScreen()
    })
  }
  
  static func getLandingScreen() -> UIViewController? {
    guard let landingScreenVC = LandingScreenViewController.instantiate() else {
      print("Failed to create Landing Screen VC")
      return nil
    }
    return landingScreenVC
  }
  
  func continueToLandingScreen() {
    print("Continuing to Landing Screen")
    DispatchQueue.main.async {
      if let landingVC = LoadingScreenViewController.getLandingScreen() {
        self.navigationController?.setViewControllers([landingVC], animated: true)
      }
    }
  }
  
  static func getMainScreenVC() -> UIViewController? {
    if DataStore.shared.remoteConfig.configValue(forKey: "waitlist_enabled").boolValue {
      guard let waitlistVC = GetStartedWaitlistViewController.instantiate() else {
        print("Failed to create Waitlist VC")
        return nil
      }
      return waitlistVC
    } else {
      guard let mainVC = MainTabBarViewController.instantiate() else {
        print("Failed to create Simple Discovery VC")
        return nil
      }
      return mainVC
    }
  }
  
  static func getWaitlistVC() -> UIViewController? {
    guard let waitlistVC = GetStartedWaitlistViewController.instantiate() else {
      print("Failed to create Landing Screen VC")
      return nil
    }
    return waitlistVC
  }
  
  func continueToMainScreen() {
    print("Continuing to Main Screen")
    DispatchQueue.main.async {
      if let mainVC = LoadingScreenViewController.getMainScreenVC() {
        self.navigationController?.setViewControllers([mainVC], animated: true)
      }
    }
  }
  
  func testImageUpload() {
    if let testImage = UIImage(named: "sample-profile-brooke-1") {
      let testUserID = "5c82162afec46c84e924a332"
      ImageUploadAPI.shared.uploadNewImage(with: testImage, userID: testUserID, test: true) { (result) in
        print("Image upload returned")
        switch result {
        case .success( let imageAllSizesRepresentation):
          print("Finished Image Test Successfully")
          print(imageAllSizesRepresentation)
        case .failure(let error):
          print("Failed image api request")
          print(error)
        }
      }
    } else {
      fatalError("Failed to create image for image upload test")
    }
    
  }
  
}
