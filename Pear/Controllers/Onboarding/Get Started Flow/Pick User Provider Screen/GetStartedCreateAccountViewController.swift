//
//  GetStartedCreateAccountViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Firebase

class GetStartedCreateAccountViewController: UIViewController {
  
  var gettingStartedData: UserProfileCreationData!
  var authAPI: AuthAPI! =  FakeAuthAPI()
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedData: UserProfileCreationData) -> GetStartedCreateAccountViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedCreateAccountViewController.self), bundle: nil)
    guard let createAccountVC = storyboard.instantiateInitialViewController() as? GetStartedCreateAccountViewController else { return nil }
    createAccountVC.gettingStartedData = gettingStartedData
    return createAccountVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func facebookButtonClicked(_ sender: Any) {
    
  }
  
  @IBAction func emailButtonClicked(_ sender: Any) {
    guard let emailVC = GetStartedCreateAccountEmailViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
      print("Failed to create Create Account Email VC")
      return
    }
    self.navigationController?.pushViewController(emailVC, animated: true)
  }
  
}

// MARK: - Life Cycle
extension GetStartedCreateAccountViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
}
