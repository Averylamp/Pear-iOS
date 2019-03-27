//
//  ApproveProfileNavigationViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/26/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ApproveDetachedProfileNavigationViewController: UINavigationController {
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(detachedProfile: PearDetachedProfile) -> ApproveDetachedProfileNavigationViewController? {
    let storyboard = UIStoryboard(name: String(describing: ApproveDetachedProfileNavigationViewController.self), bundle: nil)
    guard let detachedProfileNavVC = storyboard.instantiateInitialViewController() as? ApproveDetachedProfileNavigationViewController else { return nil }
    
    guard let detachedProfileFoundVC = ApproveDetachedProfileFoundViewController.instantiate(detachedProfile: detachedProfile) else {
      print("Failed to create Detached Profile Found VC")
      return nil
    }
    detachedProfileNavVC.viewControllers = [detachedProfileFoundVC]
    
    detachedProfileNavVC.isNavigationBarHidden = true
    return detachedProfileNavVC
  }
  
}

// MARK: - Life Cycle
extension ApproveDetachedProfileNavigationViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
   }
}
